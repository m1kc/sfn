/*
 * sfn.d
 *
 * Copyright 2012 m1kc <m1kc@yandex.ru>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 */

import std.stdio;
import std.file;
import std.socket;
import std.socketstream;
import std.getopt;
import std.conv;
import std.string;
import core.thread;

__gshared bool localDone = false;
__gshared bool remoteDone = false;
__gshared SocketStream stream = null;
__gshared Socket listener = null;
__gshared Socket socket = null;
__gshared string[] send;

immutable uint windowSize = 1024*64;

void main(string[] args)
{
	bool server = false;
	string connect = null;
	ushort port = 3214;
	bool help = false;
	bool ver = false;

	getopt(args,
		"version|v", &ver,
		"help|h", &help,
		"listen|l|s", &server,
		"connect|c", &connect,
		"port|p", &port,
	);
	send = args[1..$];

	if (help) { usage(true); return; }
	if (ver) { writeln("sfn 1.0"); return; }

	if ((connect is null) && !server) { usage(false, "You must specify mode."); return; }
	if ((connect !is null) && server) { usage(false, "You must specify only one mode."); return; }

	if (server)
	{
		listener = new TcpSocket();
		assert(listener.isAlive);
		listener.bind(new InternetAddress(port));
		listener.listen(10);
		writeln("Waiting for connection...");
		socket = listener.accept();
		writeln("Connected: " ~ to!string(socket.remoteAddress()));
		stream = new SocketStream(socket);
	}
	else
	{
		writeln("Connecting...");
		socket = new TcpSocket(new InternetAddress(connect, port));
		writeln("Connected.");
		stream = new SocketStream(socket);
	}
	scope(exit)
	{
		stream.close();
		socket.close();
		if (listener !is null) listener.close();
	}
	Thread receiver = new Thread( &receiveFiles );
	receiver.start();
	Thread sender = new Thread( &sendFiles );
	sender.start();
	writeln("Started transfer.");
	// wait
	while(!localDone || !remoteDone) Thread.sleep( dur!("msecs")(100) );
	writeln("Transfer complete.");
	return;
}

void receiveFiles()
{
	immutable ubyte FILE = 0x01;
	immutable ubyte DONE = 0x02;

	ubyte b;
	
	while(true)
	{
		stream.read(b);
		if (b == DONE)
		{
			writeln("Remote done.");
			remoteDone = true;
			return;
		}
		else if (b == FILE)
		{
			write("Receiving a file: ");
			string filename = to!string(stream.readLine());
			write(filename ~ ", ");
			ulong size;
			stream.read(size);
			writeln(size, " bytes");

			File f = File(filename, "w");
			
			ubyte[] buf = new ubyte[windowSize];
			ulong remain = size;
			ulong readc;
			ulong sentBars;
			while(remain > 0)
			{
				sentBars = (size-remain)*21/size;
				write("[");
				for (int i=0; i<20; i++) write(i<sentBars ? "#" : "-");
				write("] ");
				write(remain, " bytes left \r");
				
				if (remain < windowSize) buf = new ubyte[cast(uint)(remain)];
				readc = stream.read(buf);
				remain -= readc;
				f.rawWrite(buf[0..cast(uint)(readc)]);
			}
			writeln();
			writeln("Done.");
			f.close();
		}
		else
		{
			writeln("Unexpected byte " ~ to!string(b));
		}
	}
}

void sendFiles()
{
	immutable ubyte FILE = 0x01;
	immutable ubyte DONE = 0x02;

	foreach(string s; send)
	{
		writeln("Sending a file: " ~ s);
		DirEntry d = dirEntry(s);
		if (d.isFile())
		{
			stream.write(FILE);
			File f = File(s, "r");
			version(Windows)
			{
				stream.writeString(f.name.split("\\")[$-1]);
				stream.writeString("\n");
			}
			else
			{
				stream.writeString(f.name.split("/")[$-1]);
				stream.writeString("\n");
			}
			stream.write(f.size());
			writeln(to!string(f.size()) ~ " bytes");
			ulong sent = 0;
			foreach (ubyte[] b; f.byChunk(windowSize))
			{
				stream.write(b);
				sent += b.length;
				write(sent, " bytes sent\r");
			}
			writeln();
			writeln("Done.");
			f.close();
		}
		else
		{
			writeln("Error: does not exist or is not a file");
		}
	}

	stream.write(DONE);
	localDone = true;
	writeln("Local done.");
}

void usage(bool desc = false, string error = null)
{
	if (error !is null) writeln(error);
	if (desc) write("sfn - send files over network. ");
	write("Usage:

    sfn --listen [options] [files to send]
    sfn --connect <address> [options] [files to send]

sfn will establish a connection, send all the files, receive all the files from another side and then exit.

Options:

    --version, -v     Show sfn version and exit.
    --help, -h        Show this text and exit.
    --port, -p        Use specified port. Defaults to 3214.

");

}
