---
layout: post
title: 'EOL rubies and semantic versioning'
tags: [ruby, semver]
---
I’ve seen this issue come up a couple of times in some open source ruby Gems. People think that removing 1.8.7 and 1.9.2 support is something they should do now since its been announcing that those Ruby versions are officially EOL.

In my opinion, it doesn’t matter if its EOL upstream, if you break 1.8.7 support now without a major version number increment, you are violating semantic versioning.

I had the thought of blogging about this after this discussion in [VCR](https://github.com/vcr/vcr) happened:
https://github.com/vcr/vcr/commit/8b5bf67b0885fd28042302b15fc365fe64ab9599#commitcomment-9330716

Personally, I don’t have much real world experience with breaking people’s 1.8.7 stuff, so I was glad [@sigmavirus24](https://github.com/vcr/vcr/commit/8b5bf67b0885fd28042302b15fc365fe64ab9599#commitcomment-9330716) chimed in here. I guess [@krainboltgreene](https://github.com/krainboltgreene) could just make the next Gem release be 3.0 and it would be fine. Should you release a new version merely because you want to stop supporting minor versions?

If you have any thoughts on this, please leave me a comment!
