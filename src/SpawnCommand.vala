/*
 * Commandeer <https://launchpad.net/commandeer>
 *
 * Copyright (C) 2009 Jacob Peddicord <jpeddicord@ubuntu.com>
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
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

namespace Commandeer {

	class SpawnCommand : GLib.Object {
    
		public Pid child_pid;
		public Posix.pid_t child_pid_t;
		public signal void child_finished (int status);
    
		public SpawnCommand (string[] cmd) {
			try {
				Process.spawn_async_with_pipes (null, cmd, null, SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out child_pid, null, null, null);
				ChildWatch.add (child_pid, this.child_ended);
			} catch (SpawnError e) {
				error ("Unable to spawn!");
			}
			child_pid_t = (Posix.pid_t) child_pid;
		}
    
		public void child_ended (Pid pid, int status) {
			debug ("Child ended with status %d", status);
			child_finished (status);
		}
    
		public void terminate () {
			debug ("Terminating %d", (int) child_pid);
			Posix.kill (child_pid_t, 15); // SIGTERM
		}
    
		public void pause () {
			debug ("Pausing %d", (int) child_pid);
			Posix.kill (child_pid_t, 19); // SIGSTOP
		}
    
		public void resume () {
			debug ("Resuming %d", (int) child_pid);
			Posix.kill (child_pid_t, 18); // SIGCONT
		}

	}
	
}
