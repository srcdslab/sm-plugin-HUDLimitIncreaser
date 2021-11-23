#include <sourcemod>
#include <sdktools>

public Plugin myinfo = 
{
	name = "HUD Limit Increaser",
	author = "gubka, SHUFEN, maxime1907",
	description = "Increase HUD limit for money, heath, armor and ammo",
	version = "1.0",
	url = "https://gitlab.com/counterstrikeglobaloffensive/sm-plugins/hudlimitincreaser"
}

public void OnPluginStart()
{
    FindConVar("sv_sendtables").SetInt(1);

    // Loads a gamedata configs file
    Handle hConfig = LoadGameConfigFile("HUDLimitIncreaser.games");

    // Load other offsets
    int iBits                            = GameConfGetOffset(hConfig,  "CSendProp::m_nBits");
    Address g_SendTableCRC                = GameConfGetAddress(hConfig, "g_SendTableCRC");
    Address m_ArmorValue                = GameConfGetAddress(hConfig, "m_ArmorValue");
    Address m_iAccount                    = GameConfGetAddress(hConfig, "m_iAccount");
    Address m_iHealth                    = GameConfGetAddress(hConfig, "m_iHealth");
    Address m_iClip1                    = GameConfGetAddress(hConfig, "m_iClip1");
    Address m_iPrimaryReserveAmmoCount    = GameConfGetAddress(hConfig, "m_iPrimaryReserveAmmoCount");
    Address m_iSecondaryReserveAmmoCount    = GameConfGetAddress(hConfig, "m_iSecondaryReserveAmmoCount");

    // Memory patching
    int iPatch = 0;
    if (GetEngineVersion() == Engine_CSGO)
        iPatch = 32;
    else if (GetEngineVersion() == Engine_CSS)
        iPatch = 17;

    StoreToAddress(m_ArmorValue + view_as<Address>(iBits), iPatch, NumberType_Int32);
    StoreToAddress(m_iAccount + view_as<Address>(iBits), iPatch, NumberType_Int32);
    StoreToAddress(m_iHealth + view_as<Address>(iBits), iPatch, NumberType_Int32);
    StoreToAddress(m_iClip1 + view_as<Address>(iBits), iPatch, NumberType_Int32);
    StoreToAddress(m_iPrimaryReserveAmmoCount + view_as<Address>(iBits), iPatch, NumberType_Int32);
    StoreToAddress(m_iSecondaryReserveAmmoCount + view_as<Address>(iBits), iPatch, NumberType_Int32);

    /// 1337 -> it just a random and an invalid CRC32 byte
    StoreToAddress(g_SendTableCRC, 1337, NumberType_Int32);
}
