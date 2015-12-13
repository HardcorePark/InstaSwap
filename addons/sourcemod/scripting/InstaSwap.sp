#pragma semicolon 1

#define PLUGIN_VERSION "2.15"
#define PLUGIN_PREFIX "[\x06InstaSwap\x01]"

#include <sourcemod>

public Plugin myinfo = 
{
	name = "Instant-Swap",
	author = "Oscar Wos (OSWO)",
	description = "Instant-Swap",
	version = PLUGIN_VERSION,
	url = "www.tangoworldwide.net",
};

bool g_CTLocked = false;
Handle g_AutoUnlock = INVALID_HANDLE;

public void OnPluginStart()
{
	RegConsoleCmd("jointeam", Event_Join, "", 0);
	RegAdminCmd("sm_lockct", Command_Lockct, ADMFLAG_CUSTOM1);
}

public void OnMapStart()
{
	g_CTLocked = false;
}

public void OnClientPutInServer()
{
	CheckPlayers();
}

public void OnClientDisconnect()
{
	CheckPlayers();
}

public Action Event_Join(client, args)
{
	if(IsValidPlayer(client))
	{
		char l_TeamArg[4];
		GetCmdArg(1, l_TeamArg, sizeof(l_TeamArg));
		int l_TeamNum = StringToInt(l_TeamArg);
		
		bool isAdminOverride = false;
		AdminId clientAdminId = GetUserAdmin(client);
		if (clientAdminId != INVALID_ADMIN_ID)
		{
			if (GetAdminFlag(clientAdminId, Admin_Ban))
			{
				isAdminOverride = true;
			}
		}
		
		if (l_TeamNum == 3 && g_CTLocked == true && isAdminOverride == false)
		{
			PrintToChat(client, "%s You have been denied \x10CT \x01due to there being a \x07CT-Lock!", PLUGIN_PREFIX);
		}
		else 
		{
			char l_TeamName[64];
			char l_PlayerName[64];
			GetClientName(client, l_PlayerName, sizeof(l_PlayerName));
			
			if(l_TeamNum == 1)
			{
				Format(l_TeamName, sizeof(l_TeamName), "Spec");
			}
			else if(l_TeamNum == 2)
			{
				Format(l_TeamName, sizeof(l_TeamName), "T");
			}
			else
			{
				Format(l_TeamName, sizeof(l_TeamName), "CT");
			}
			
			ChangeClientTeam(client, l_TeamNum);
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if(IsValidPlayer(i))
				{
					PrintToConsole(i, "[InstaSwap] Player %s - Team: %s", l_PlayerName, l_TeamName);
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action Command_Lockct(client, args)
{
	if (args != 0)
	{
		PrintToChat(client, "%s Too many Arguements!", PLUGIN_PREFIX);
		return Plugin_Handled;
	}
	
	if (g_CTLocked == false)
	{
		PrintToChat(client, "%s \x07CT-Lock \x01has now been activated!", PLUGIN_PREFIX);
		g_CTLocked = true;
	} 
	else if (g_CTLocked == true)
	{
		PrintToChat(client, "%s \x07CT-Lock \x01has now been disabled!", PLUGIN_PREFIX);
		g_CTLocked = false;
	}
	
	return Plugin_Handled;
}

public CheckPlayers()
{
	int g_CurrentAdmins = 0;
	
	for (int i = 0; i <= MaxClients; i++)
	{
		if (IsValidPlayer(i))
		{
			AdminId l_Player = GetUserAdmin(i);
			if (l_Player != INVALID_ADMIN_ID)
			{
				if (GetAdminFlag(l_Player, Admin_Custom1))
				{
					g_CurrentAdmins++;
				}
			}
		}
	}
	
	if (g_CurrentAdmins == 0)
	{
		g_AutoUnlock = CreateTimer(300.0, noAdminsUnlock);
	}
	else
	{
		if (g_AutoUnlock != INVALID_HANDLE)
		{
			CloseHandle(g_AutoUnlock);
			g_AutoUnlock = INVALID_HANDLE;
		}
	}
}

public Action noAdminsUnlock(Handle timer)
{
	if (g_CTLocked == true)
	{
		PrintToChatAll("%s \x07CT-Lock \x01has been disabled due to \x05No Un-Locking Admins \x01online!", PLUGIN_PREFIX);
		g_CTLocked = false;
		
		g_AutoUnlock = INVALID_HANDLE;
	}
}
stock bool IsValidPlayer(int client, bool alive = false)
{
   if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
   {
       return true;
   }
   return false;
}