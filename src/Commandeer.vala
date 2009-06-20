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

class Commandeer : Window {
    
    static int arg_delay;
    static bool arg_pause;
    static bool arg_cancel;
    static bool arg_stop;
    static string arg_title;
    static string arg_text;
    const OptionEntry[] options = {
        { "delay", 'd', 0, OptionArg.INT, ref arg_delay, "Delay before execution. If -1, disable the timer.", "SECONDS" },
        { "pause", 'p', OptionFlags.OPTIONAL_ARG, OptionArg.NONE, ref arg_pause, "Enable execution pausing." },
        { "cancel", 'c', OptionFlags.OPTIONAL_ARG, OptionArg.NONE, ref arg_cancel, "Enable cancellation before command is run. Only valid if --delay is set." },
        { "stop", 's', OptionFlags.OPTIONAL_ARG, OptionArg.NONE, ref arg_stop, "Enable cancellation during execution. Implies --cancel." },
        { "title", 't', 0, OptionArg.STRING, out arg_title, "Command title.", "TITLE" },
        { "text", 't', 0, OptionArg.STRING, out arg_text, "Dialog text.", "TEXT" },
        { null }
    };
    
    static string[] command;
    private bool paused = false;
    private bool running = false;
    private SpawnCommand spawn;
    
    // once the delay is set, the countdown begins
    private int remaining = 0;
    private int _delay = 0;
    public int delay {
        get { return _delay; }
        set {
            // only enable the timer for positive values
            if (value > 0) {
                remaining = value;
                Timeout.add_seconds (1, delay_timer);
            } else if (value == 0) {
                run_command ();
            }
            _delay = value;
        }
    }
    
    private VBox vbox;
    private HButtonBox action_area;
    private Button pause_btn;
    private Button cancel_btn;
    private Button start_btn;
    private Label information;
    private MessageDialog quit_dlg;
    
    public Commandeer () {
        this.title = "Commandeer";
        this.destroy += Gtk.main_quit;
        this.position = WindowPosition.CENTER;
        this.deletable = false;
        this.skip_pager_hint = true;
        this.stick ();
        this.set_keep_above (true);
        
        vbox = new VBox (false, 0);
        vbox.border_width = 10;
        this.add (vbox);
        
        action_area = new HButtonBox ();
        action_area.layout_style = ButtonBoxStyle.END;
        action_area.spacing = 5;
        vbox.pack_end (action_area, false, true, 0);
        
        if (arg_cancel) {
            cancel_btn = new Button.from_stock (STOCK_CANCEL);
            action_area.pack_start (cancel_btn, true, true, 0);
            cancel_btn.clicked += (s) => {
                quit_dlg = new MessageDialog (this, DialogFlags.MODAL, MessageType.WARNING, ButtonsType.NONE, "Are you sure you want to stop %s?", arg_title);
                quit_dlg.add_button ("Continue", 1);
                quit_dlg.add_button (STOCK_STOP, ResponseType.CANCEL);
                quit_dlg.response += (s, response) => {
                    if (response == ResponseType.CANCEL) {
                        if (running) {
                            spawn.terminate ();
                        }
                        main_quit ();
                    }
                    quit_dlg.destroy ();
                };
                quit_dlg.run ();
            };
        }
        if (arg_pause) {
            pause_btn = new Button.from_stock (STOCK_MEDIA_PAUSE);
            action_area.pack_end (pause_btn, true, true, 0);
            pause_btn.sensitive = false;
            pause_btn.clicked += (s) => {
                if (paused) {
                    spawn.resume ();
                    paused = false;
                    lock_screen ();
                    pause_btn.label = STOCK_MEDIA_PAUSE;
                } else {
                    spawn.pause ();
                    paused = true;
                    unlock_screen ();
                    pause_btn.label = "Resume";
                }
                update_info ();
            };
        }
        if (arg_delay != 0) {
            start_btn = new Button.with_label ("Start");
            action_area.pack_end (start_btn, true, true, 0);
            start_btn.clicked += (s) => {
                run_command ();
            };
        }
        
        information = new Label ("Commandeer");
        information.use_markup = true;
        information.wrap = true;
        vbox.pack_start (information, true, true, 5);
        
        update_info ();
    }
    
    // check & update the timer state (called via timeout)
    public bool delay_timer () {
        if (running) {
            remaining = 0;
            return false;
        }
        remaining--;
        if (remaining == 0) {
            run_command ();
            return false;
        }
        update_info ();
        return true;
    }
    
    public void lock_screen () {
        deiconify ();
        fullscreen ();
        stick ();
        set_keep_above (true);
    }
    
    public void unlock_screen () {
        unfullscreen ();
    }
    
    public int run_command () {
        debug ("Running %s", command[0]);
        running = true;
        spawn = new SpawnCommand (command);
        spawn.child_finished += (s, status) => {
            string msg;
            MessageType msgtype;
            if (status == 0) {
                msg = "%s has completed.";
                msgtype = MessageType.INFO;
            } else {
                msg = "%s did not complete successfully.";
                msgtype = MessageType.ERROR;
            }
            quit_dlg = new MessageDialog (this, DialogFlags.MODAL, msgtype, ButtonsType.CLOSE, msg, arg_title);
            quit_dlg.run ();
            main_quit ();
        };
        // lock up the desktop and update the UI
        if (arg_stop) { cancel_btn.label = STOCK_STOP; }
        else if (arg_cancel) { cancel_btn.sensitive = false; }
        if (arg_pause) { pause_btn.sensitive = true; }
        if (arg_delay != 0) { start_btn.sensitive = false; }
        lock_screen ();
        update_info ();
        return 0;
    }
    
    private void update_info () {
        string infotext = "";
        if (running) {
            infotext += "<big>Running %s</big>".printf(arg_title);
        } else {
            infotext += "<big>About to run %s</big>".printf(arg_title);
        }
        if (paused) { infotext += " (Paused)"; }
        if (arg_text != null) { infotext += "\n\n%s".printf(arg_text); }
        infotext += "\n\n";
        if (arg_cancel) {
            if (arg_stop) {
                infotext += "This operation may be stopped.";
            } else {
                infotext += "<b>Once started, this operation may not be stopped.</b>";
            }
        } else {
            infotext += "<b>This operation can not be stopped.</b>";
        }
        if ((!arg_cancel || !arg_stop) && arg_pause) {
            infotext += " However, it may be paused.";
        }
        infotext += "\n\n";
        if (!running) {
            if (arg_delay == -1) {
                infotext += "Click Start to begin.";
            } else if (remaining != 0) {
                infotext += "Starting in %d seconds.".printf(remaining);
            }
        }
        information.label = infotext;
    }
    
    public static int main (string[] args) {
        // parse for options
        try {
            var context = new OptionContext ("-- COMMAND");
            context.set_help_enabled (true);
            context.add_main_entries (options, null);
            context.parse (ref args);
        } catch (OptionError e) {
            print ("%s\n", e.message);
            return 1;
        }
        
        if (arg_stop) {
            arg_cancel = true;
        }
        
        // extract the command to run
        if (args.length == 1) {
            print ("No command specified.\n");
            return 1;
        }
        command = new string[args.length - 1];
        for (int i = 0; i < args.length; i++) {
            if (i > 0) {
                command[i - 1] = args[i];
            }
        }
        
        // use the command name for the title if not specified
        if (arg_title == null) {
            arg_title = command[0];
        }
        
        // start!
        Gtk.init (ref args);
        var dialog = new Commandeer ();
        dialog.delay = arg_delay;
        dialog.show_all ();
        
        // fire it up
        Gtk.main ();
        return 0;
    }
    
}
