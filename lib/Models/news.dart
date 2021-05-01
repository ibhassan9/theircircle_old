import 'package:unify/Models/course.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:quiver/iterables.dart';

class News {
  String title;
  String url;
  String imgUrl;

  News({this.title, this.url, this.imgUrl});
}

final uoftScraper = WebScraper('https://www.utoronto.ca');
final yorkUScraper = WebScraper('https://yfile.news.yorku.ca');
final westernUScraper = WebScraper('https://news.westernu.ca');

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

Future<String> grabImgUrl({String url}) async {
  String uri = '';
  await yorkUScraper
      .loadWebPage(url.replaceAll('https://yfile.news.yorku.ca', ''))
      .then((value) {
    var scrape2 = yorkUScraper.getElement(
        'div.hfeed > div.container > section.primary > article > div.entry > div.wp-caption > img',
        ['src']);
    var element = scrape2.first;
    var attributes = element['attributes'];
    var src = attributes['src'];
    uri = src;
  }).catchError((e) {
    uri = '';
  });
  return uri;
}

Future<List<News>> scrapeWesternUNews() async {
  List<News> news = [];
  if (await westernUScraper.loadWebPage('/campus/')) {
    var scrape = westernUScraper.getElement(
        'div.et_pb_row > div.et_pb_column > div.et_pb_module > div.et_pb_blog_grid > div.et_pb_ajax_pagination_container > div.et_pb_salvattore_content > article.et_pb_post > h2.entry-title > a',
        ['href']);
    var scrapeF = westernUScraper.getElement(
        'div.et_pb_row > div.et_pb_column > div.et_pb_module > div.et_pb_blog_grid > div.et_pb_ajax_pagination_container > div.et_pb_salvattore_content > article.et_pb_post > div.et_pb_image_container > a > img',
        ['src']);
    for (var i = 0; i < scrapeF.length; i++) {
      if (scrape[i]['title'].toString().contains('<a href')) {
      } else {
        var element = scrape[i];
        var imgElement = scrapeF[i];
        var title = element['title'].toString();
        var t = title.replaceAll("\n", "");
        var url = element['attributes']['href'].toString();
        var imgUrl = imgElement['attributes']['src'].toString().trim();
        var n = News(title: '${t.trim()}', url: "$url", imgUrl: imgUrl);
        news.add(n);
      }
    }
  }

  return news;
}

Future<Null> scrapeCoursesYork(String faculty, String subject) async {
  var page = WebScraper("https://w2prod.sis.yorku.ca/Apps/WebObjects/cdm");
  if (await page.loadWebPage(
      '.woa/wa/crsq1?faculty=$faculty&subject=$subject&academicyear=2020&studysession=fw')) {
    var scrape2 = page.getElement(
        'tbody > tr > td > table > tbody > tr > td > table > tbody > tr > td > table > tbody > tr > td',
        ['class']);

    if (scrape2.isNotEmpty) {
      scrape2.removeAt(0);
      scrape2.removeAt(0);
      scrape2.removeWhere((item) =>
          item['title'].toString().contains('Fall/Woverpass 2020-2021'));

      var chunks = partition(scrape2, 3);

      for (var chunk in chunks) {
        var title = chunk[0]['title'];
        var description = chunk[1]['title'];
        await createCourse(
            title.toString().replaceAll("  ", "").trim(), description);
      }
    }
  }
}
