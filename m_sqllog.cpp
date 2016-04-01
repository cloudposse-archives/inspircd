/*       +------------------------------------+
 *       | Inspire Internet Relay Chat Daemon |
 *       +------------------------------------+
 *
 *  InspIRCd: (C) 2002-2010 InspIRCd Development Team
 * See: http://wiki.inspircd.org/Credits
 *
 * This program is free but copyrighted software; see
 *      the file COPYING for details.
 *
 * Author: Jakub Kosiński <jakub@kosinski.info>
 *
 * ---------------------------------------------------
 */

#include "inspircd.h"
#include "sql.h"

/* $ModDesc: Allows storage of channel messages in a SQL table */

class MessageLogQuery : public SQLQuery
{
 public:
  MessageLogQuery(Module* me)
    : SQLQuery(me)
  {
  }

  void OnResult(SQLResult& res)
  {
  }

  void OnError(SQLerror& error)
  {
    ServerInstance->Logs->Log("m_sqllog", DEFAULT, "SQLLOG: query failed (%s)", error.Str());
  }
};

class ModuleSQLLog : public Module
{
  LocalIntExt pendingExt;
  dynamic_reference<SQLProvider> SQL;
  std::string query;

public:
  ModuleSQLLog() : pendingExt("sqlauth-wait", this), SQL(this, "SQL")
  {
  }

  void init()
  {
    ServerInstance->Modules->AddService(pendingExt);
    OnRehash(NULL);
    Implementation eventlist[] = { I_OnRehash, I_OnUserPreMessage, I_OnUserPreNotice, I_OnUserJoin, I_OnUserPart, I_OnPreTopicChange };
    ServerInstance->Modules->Attach(eventlist, this, 6);
  }

  void OnRehash(User* user)
  {
    ConfigTag* conf = ServerInstance->Config->ConfValue("sqllog");
    std::string dbid = conf->getString("dbid");
    query = conf->getString("query");
    if (dbid.empty())
      SQL.SetProvider("SQL");
    else
      SQL.SetProvider("SQL/" + dbid);
  }

  void LogMessage(User* user, const std::string &dest_name, const std::string &text, const std::string &event)
  {
      if (!SQL)
      {
          ServerInstance->Logs->Log("m_sqllog", DEFAULT, "SQLLOG: SQL database not present");
      }
      else if (query.empty())
      {
          ServerInstance->Logs->Log("m_sqllog", DEFAULT, "SQLLOG: SQL query is not provided");
      }
      else
      {
          ParamM queryInfo;
          SQL->PopulateUserInfo(user, queryInfo);
          queryInfo["nick"] = user->nick;
          queryInfo["host"] = user->host;
          queryInfo["channel"] = dest_name;
          queryInfo["event"] = event;
          queryInfo["message"] = text;
          SQL->submit(new MessageLogQuery(this), "INSERT INTO events (nick, host, ip, user_name, ident, server, channel, event, message) VALUES ('$nick', '$host', '$ip', '$gecos', '$ident', '$server', '$channel', '$event', '$message')", queryInfo);
      }
  }

  ModResult OnPreTopicChange(User* user, Channel* channel, const std::string &text)
  {
      LogMessage(user, channel->name, text, std::string("topic"));
      return MOD_RES_PASSTHRU;
  }

  ModResult OnUserPreMessage(User* user,void* dest,int target_type, std::string &text, char status, CUList &exempt_list)
  {
      if (target_type == TYPE_CHANNEL) {
          Channel* channel = (Channel*) dest;
          LogMessage(user, channel->name, text, std::string("message"));
      }
      else if (target_type == TYPE_USER) {
          User* u = (User*) dest;
          LogMessage(user, u->nick, text, std::string("privmsg"));
      }
      return MOD_RES_PASSTHRU;
  }

  ModResult OnUserPreNotice(User* user,void* dest,int target_type, std::string &text, char status, CUList &exempt_list)
  {
      if (target_type == TYPE_CHANNEL) {
          Channel* channel = (Channel*) dest;
          LogMessage(user, channel->name, text, std::string("notice"));
      }
      else if (target_type == TYPE_USER) {
          User* u = (User*) dest;
          LogMessage(user, u->nick, text, std::string("privnotice"));
      }
      return MOD_RES_PASSTHRU;
  }

  void OnUserJoin(Membership* memb, bool sync, bool created, CUList& excepts)
  {
      LogMessage(memb->user, memb->chan->name, std::string(), std::string("join"));
  }

  void OnUserPart(Membership* memb, std::string &partmessage, CUList& except_list)
  {
      LogMessage(memb->user, memb->chan->name, partmessage, std::string("part"));
  }

  Version GetVersion()
  {
    return Version("Allows storage of channel messages in a SQL table", VF_VENDOR);
  }

};

MODULE_INIT(ModuleSQLLog)
