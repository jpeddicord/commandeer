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

using Gtk;

namespace Commandeer {

    class Wizard : GLib.Object {
        
        public Builder builder;
        public Dialog dialog;
        
        public AboutDialog dlg_about;
        public Button btn_about;
        
        construct {
            builder = new Builder ();
            string filename;
            
            if (FileUtils.test ("commandeer.ui", FileTest.EXISTS)) {
                filename = "commandeer.ui";
            } else {
                filename = "%s/commandeer.ui".printf(Build.DATADIR);
            }
            
            try {
                builder.add_from_file (filename);
            } catch (Error e) {
                error ("Could not load UI: %s", e.message);
            }
            
            // about trigger
            dlg_about = builder.get_object ("about") as AboutDialog;
            btn_about = builder.get_object ("btn_about") as Button;
            btn_about.clicked.connect((s) => {
				dlg_about.show_all ();
            });
            
            // the dialog itself
            dialog = builder.get_object ("wizard") as Dialog;
            dialog.destroy += Gtk.main_quit;
            dialog.show_all ();
            
        }

    }

}
