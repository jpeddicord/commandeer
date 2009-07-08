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
        public Clipboard clipboard;
        
        private AboutDialog dlg_about;
        private Button btn_about;
        private Entry txt_title;
        private Entry txt_command;
        private CheckButton ck_pause;
        private CheckButton ck_cancel;
        private CheckButton ck_stop;
        private RadioButton delay_instant;
        private RadioButton delay_user;
        private RadioButton delay_timed;
        private Adjustment delay_secs;
        private Entry txt_description;
        private Label result;
        private Button btn_copy;
        
        construct {
            builder = new Builder ();
            clipboard = Clipboard.get (Gdk.SELECTION_CLIPBOARD);
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
            dlg_about.response.connect ((s) => { dlg_about.hide (); });
            btn_about = builder.get_object ("btn_about") as Button;
            btn_about.clicked.connect((s) => {
				dlg_about.run ();
            });
            
            // dialog widgets
            txt_title = builder.get_object ("title") as Entry;
            txt_title.changed.connect ((s) => { update_result (); });
            
            txt_command = builder.get_object ("command") as Entry;
            txt_command.changed.connect ((s) => { update_result (); });
            
            ck_pause = builder.get_object ("pause") as CheckButton;
            ck_pause.toggled.connect ((s) => { update_result (); });
            
            ck_cancel = builder.get_object ("cancel") as CheckButton;
            ck_cancel.toggled.connect ((s) => {
                if (!s.active) {
                    ck_stop.active = false;
                }
                update_result ();
            });
            
            ck_stop = builder.get_object ("stop") as CheckButton;
            ck_stop.toggled.connect ((s) => {
                if (s.active) {
                    ck_cancel.active = true;
                }
                update_result ();
            });
            
            delay_instant = builder.get_object ("delay_instant") as RadioButton;
            delay_instant.toggled.connect ((s) => { update_result (); });
            
            delay_user = builder.get_object ("delay_user") as RadioButton;
            delay_user.toggled.connect ((s) => { update_result (); });
            
            delay_timed = builder.get_object ("delay_timed") as RadioButton;
            delay_timed.toggled.connect ((s) => { update_result (); });
            
            delay_secs = builder.get_object ("delay_adjustment") as Adjustment;
            delay_secs.value_changed.connect ((s) => { update_result (); });
            
            txt_description = builder.get_object ("description") as Entry;
            txt_description.changed.connect ((s) => { update_result (); });
            
            result = builder.get_object ("result") as Label;
            
            btn_copy = builder.get_object ("btn_copy") as Button;
            btn_copy.clicked.connect ((s) => {
                clipboard.set_text (result.label, -1);
            });
            
            // the dialog itself
            dialog = builder.get_object ("wizard") as Dialog;
            dialog.destroy.connect (Gtk.main_quit);
            dialog.show_all ();
            
        }
        
        private void update_result () {
            string flags = "";
            
            if (ck_pause.active) {
                flags += " -p";
            }
            if (ck_stop.active) {
                flags += " -s";
            } else if (ck_cancel.active) {
                flags += " -c";
            }
            
            if (delay_user.active) {
                flags += " -d -1";
            } else if (delay_timed.active) {
                flags += " -d %d".printf((int) delay_secs.value);
            }
            
            if (txt_title.text.len() > 0) {
                flags += " --title \"%s\"".printf(txt_title.text);
            }
            if (txt_description.text.len() > 0) {
                flags += " --text \"%s\"".printf(txt_description.text);
            }
            
            result.label = "commandeer" + flags + " -- " + txt_command.text;
        }

    }

}
