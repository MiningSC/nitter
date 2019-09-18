import strutils, sequtils, uri

import jester

import router_utils
import ".."/[query, types, utils, api, agents]
import ../views/[general, search]

export search

proc createSearchRouter*(cfg: Config) =
  router search:
    get "/search":
      if @"text".len > 200:
        resp Http400, showError("Search input too long.", cfg.title)

      let query = initQuery(params(request))

      case query.kind
      of users:
        if "," in @"text":
          redirect("/" & @"text")
        let users = await getSearch[Profile](query, @"after", getAgent())
        resp renderMain(renderUserSearch(users, Prefs()), Prefs(), path=getPath())
      of custom:
        let tweets = await getSearch[Tweet](query, @"after", getAgent())
        resp renderMain(renderTweetSearch(tweets, Prefs(), getPath()), Prefs(), path=getPath())
      else:
        resp Http404, showError("Invalid search.", cfg.title)
