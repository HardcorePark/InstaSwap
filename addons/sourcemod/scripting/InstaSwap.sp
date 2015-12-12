#pragma semicolon 1

#define PLUGIN_VERSION "2.03"

#include <sourcemod>

public Plugin myinfo = 
{
	name = "Instant-Swap",
	author = "Oscar Wos (OSWO)",
	description = "Instant-Swap",
	version = PLUGIN_VERSION,
	url = "www.tangoworldwide.net",
};

public void OnPluginStart()
{
	RegConsoleCmd("jointeam", Event_Join, "", 0);
}

public Action Event_Join(client, args)
{
	if(IsValidPlayer(client))
	{
		char g_TeamArg[4];
		GetCmdArg(1, g_TeamArg, sizeof(g_TeamArg));
		
		int g_TeamNum = StringToInt(g_TeamArg);
		ChangeClientTeam(client, g_TeamNum);
		
		char g_PlayerName[MAX_NAME_LENGTH];
		GetClientName(client, g_PlayerName, sizeof(g_PlayerName));
		
		char g_TeamName[64];
		if(g_TeamNum == 1)
		{
			Format(g_TeamName, sizeof(g_TeamName), "Spec");
		}
		else if(g_TeamNum == 2)
		{
			Format(g_TeamName, sizeof(g_TeamName), "T");
		}
		else
		{
			Format(g_TeamName, sizeof(g_TeamName), "CT");
		}
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsValidPlayer(i))
			{
				PrintToConsole(i, "[InstaSwap] Player %s - Team: %s", g_PlayerName, g_TeamName);
			}
		}
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