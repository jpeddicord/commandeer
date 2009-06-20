/*
 * config.vapi - Imports items from config.h
 */

[CCode(cheader_filename = "config.h",
	   cprefix="", lower_case_cprefix = "")]
namespace Commandeer.Build {
	public const string PACKAGE;
	public const string PACKAGE_BUGREPORT;
	public const string PACKAGE_NAME;
	public const string PACKAGE_STRING;
	public const string PACKAGE_TARNAME;
	public const string PACKAGE_VERSION;
	public const string VERSION;
}
