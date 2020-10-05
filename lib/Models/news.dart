import 'package:web_scraper/web_scraper.dart';

class News {
  String title;
  String url;
  String imgUrl;

  News({this.title, this.url, this.imgUrl});
}

final uoftScraper = WebScraper('https://www.utoronto.ca');
final yorkUScraper = WebScraper('https://yfile.news.yorku.ca');

Future<List<News>> scrapeUofTNews() async {
  List<News> news = [];
  if (await uoftScraper.loadWebPage('/news')) {
    var scrapeT = uoftScraper
        .getElement('div.view-content > div.news-home > a', ['href']);
    var scrapeF = uoftScraper.getElement(
        'div.view-content > div.news-home > a > div > div.picture > img',
        ['src']);

    for (var i = 0; i < scrapeF.length; i++) {
      if (scrapeT[i]['title'].toString().contains('<a href')) {
      } else {
        var element = scrapeT[i];
        var imgElement = scrapeF[i];
        var title = element['title'].toString();
        var t = title.replaceAll("\n", "");
        var url = element['attributes']['href'].toString();
        var imgUrl = imgElement['attributes']['src'].toString().trim();
        var n = News(
            title: '${t.trim()}',
            url: "https://www.utoronto.ca$url",
            imgUrl: imgUrl);
        news.add(n);
      }
    }

    // for (var element in scrapeT) {
    //   if (element['title'].toString().contains('<a href')) {
    //   } else {
    //     var title = element['title'].toString();
    //     var t = title.replaceAll("\n", "");
    //     var url = element['attributes']['href'].toString();
    //     var n = News(title: '${t.trim()}', url: "https://www.utoronto.ca$url");
    //     news.add(n);
    //   }
    // }
  }

  return news;
}

Future<List<News>> scrapeYorkUNews() async {
  List<News> news = [];
  if (await yorkUScraper.loadWebPage('/section/current-news/')) {
    var scrape2 = yorkUScraper.getElement(
        'div.container > section.primary > article.content-excerpt > h2.entry-title > a',
        ['href']);

    for (var element in scrape2) {
      var title = element['title'];
      var url = element['attributes']['href'];
      var n = News(title: '$title', url: '$url');
      news.add(n);
    }
  }
  return news;
}
