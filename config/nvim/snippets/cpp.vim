snippet cSharpStringToCppArray
option head
    # marshal String^ to char*
    char* str2 = (char*)(void*)Runtime::InteropServices::Marshal::StringToHGlobalAnsi(args->Name);
    # free char* (otherwise there is a memory leak?)
    Runtime::InteropServices::Marshal::FreeHGlobal((IntPtr)str2); 
