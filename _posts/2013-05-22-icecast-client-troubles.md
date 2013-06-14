---
layout: post
title: icecast client troubles
tags: [icecast, client, source, windows]
---
I'm running into a bit of trouble with my clever/hacky Icecast DJ authentication scheme. Turns out that most of the icecast clients out there don't support changing the source username from the default 'source', which I am using in my setup to authenticate source clients against a user database. The client I have been using, ShoutVST, supports this field just fine. However, since its a VST plugin, its not the best solution for all my users. 

After filing bug reports for various clients and not getting any response, I am trying to add support for changing source username to a client called B.U.T.T. (Broadcast Using This Tool). I'm not a windows dev however.

I'm not sure what alternatives exist if I am unable to patch BUTT. It might be nice if Mixlr supported multiple users for a single account, I might consider paying for their pro plan. Apparently you can also authenticate icecast sources by appending parameters to the stream url. This seems less convenient for my users though. 

If anyone is interested in helping me fix icecast clients or has any ideas for alternative solutions, please let me know in a comment. :)
