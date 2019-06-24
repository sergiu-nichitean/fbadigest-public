# FBA Digest - news aggregator for Amazon sellers

The app uses a rake task called hourly by a crontab to fetch new posts from various RSS feeds, but also directly parses websites which don't have RSS.

Other features:
* service worker for browser push notification
* automated weekly newsletter
* comments, saving posts and other blog-related features

The project is live in production at https://www.fbadigest.com/ hosted on an Amazon EC2 instance.
