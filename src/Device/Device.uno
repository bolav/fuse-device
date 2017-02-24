using Uno.UX;
using Fuse;
using Fuse.Scripting;
using Uno.Compiler.ExportTargetInterop;
namespace Bolav {

	[UXGlobalModule]
	public class Device : NativeModule 
	{
		static readonly Device _instance;
		public Device () {
			if(_instance != null) return;
			Resource.SetGlobalKey(_instance = this, "Bolav/Device");
			AddMember(new NativeProperty<string, string>("id", GetId));
			AddMember(new NativeProperty<string, string>("persistid", GetPersistId));
		}

		extern(!mobile) static string GetId()
		{
			return "1";
		}

		[Foreign(Language.ObjC)]
		extern(iOS) static string GetId() 
		@{
			UIDevice *device = [UIDevice currentDevice];

			return [[device identifierForVendor]UUIDString];
		@}

		[Foreign(Language.ObjC)]
		extern(iOS) static string GetiOSPersistId() 
		@{
			NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
			KeychainItemWrapper *kiw = [[KeychainItemWrapper alloc] initWithIdentifier:bundleId accessGroup:nil];

			NSString *uuid = [kiw objectForKey:(__bridge NSString*)kSecValueData];
			if (![uuid isEmpty])return uuid;
			uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
			[kiw setObject:@"Fuse" forKey:(id)kSecAttrAccount];
			[kiw setObject:uuid forKey:(__bridge id)(kSecValueData)];
			return uuid;
		@}


		static string GetPersistId() {
			// if defined(iOS) return GetiOSPersistId();
			return GetId();
		}

	}

}
