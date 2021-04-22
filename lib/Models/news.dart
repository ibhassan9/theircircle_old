import 'package:flutter/material.dart';
import 'package:unify/Models/course.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:quiver/iterables.dart';

class News {
  String title;
  String url;
  String imgUrl;

  News({this.title, this.url, this.imgUrl});
}

List<String> courses = [
  "SB ACTG",
  "ED ACTG",
  "GS ADLW",
  "AP ADMS",
  "GS ALDR",
  "AP ANTH",
  "GS ANTH",
  "AP ARB",
  "FA ARTH",
  "GS ARTH",
  "SB ARTM",
  "AP ASL",
  "ED AUCO",
  "ED BBED",
  "SC BC",
  "SC BCHM",
  "GS BFSL",
  "GL BIOL",
  "ED BIOL",
  "SC BIOL",
  "GS BIOL",
  "GS BLIS",
  "SC BPHS",
  "SB BSUS",
  "GL BUEC",
  "ED BUSI",
  "GS CCLW",
  "AP CCY",
  "GS CDIS",
  "GL CDNS",
  "AP CH",
  "ED CHEM",
  "GS CHEM",
  "SC CHEM",
  "GS CIVL",
  "LE CIVL",
  "AP CLST",
  "GS CLTC",
  "AP CLTR",
  "GS CLWP",
  "GS CMCT",
  "AP COGS",
  "AP COMN",
  "GL COMS",
  "LE COOP",
  "SC COOP",
  "ED COST",
  "AP CRIM",
  "GL CSLA",
  "FA DANC",
  "GS DANC",
  "ED DANC",
  "FA DATT",
  "SB DCAD",
  "AP DEMS",
  "GS DEMS",
  "FA DESN",
  "ED DEST",
  "GS DIGM",
  "AP DLLL",
  "GS DMGM",
  "ED DRAA",
  "GL DRST",
  "GS DVST",
  "SB ECON",
  "GL ECON",
  "AP ECON",
  "ED ECON",
  "GS ECON",
  "ED EDFE",
  "ED EDFR",
  "ED EDIN",
  "ED EDIS",
  "ED EDJI",
  "ED EDPJ",
  "ED EDPR",
  "ED EDST",
  "GS EDUC",
  "ED EDUC",
  "GS EECS",
  "LE EECS",
  "GS EIL",
  "SB EMBA",
  "AP EN",
  "ED EN",
  "GL EN",
  "GS EN",
  "GS ENG",
  "LE ENG",
  "GL ENSL",
  "SB ENTR",
  "SC ENVB",
  "ED ENVS",
  "GS ENVS",
  "ES ENVS",
  "ES ENVS",
  "EU ENVS",
  "AP ESL",
  "GS ESS",
  "LE ESSE",
  "SB EXCH",
  "GS FACC",
  "FA FACS",
  "ED FAST",
  "GS FILM",
  "FA FILM",
  "SB FINE",
  "AP FND",
  "SB FNEN",
  "ED FNMI",
  "SB FNSV",
  "AP FR",
  "GL FRAN",
  "ED FREN",
  "GS FREN",
  "GL FSL",
  "AP GCIN",
  "GS GEOG",
  "SC GEOG",
  "AP GEOG",
  "EU GEOG",
  "ED GEOG",
  "AP GER",
  "GS GFWS",
  "AP GK",
  "AP GKM",
  "GS GNRL",
  "GL GWST",
  "AP GWST",
  "ED HEB",
  "AP HEV",
  "SB HIMP",
  "GL HIST",
  "AP HIST",
  "GS HIST",
  "ED HIST",
  "HH HLST",
  "GS HLTH",
  "AP HND",
  "AP HREQ",
  "GS HRM",
  "AP HRM",
  "GL HUMA",
  "GS HUMA",
  "AP HUMA",
  "SB IBUS",
  "HH IHST",
  "GL ILST",
  "SB IMBA",
  "AP INDG",
  "ED INDS",
  "AP INDV",
  "GS INST",
  "GS INTE",
  "SB INTL",
  "SC ISCI",
  "AP IT",
  "GL ITEC",
  "AP ITEC",
  "GS ITEC",
  "AP JC",
  "AP JP",
  "GS JUDS",
  "GS KAHS",
  "HH KINE",
  "AP KOR",
  "AP LA",
  "GS LAL",
  "AP LASO",
  "ED LAW",
  "GS LAW",
  "GS LAWB",
  "GS LAWH",
  "GS LAWL",
  "GL LIN",
  "AP LING",
  "ED LLDV",
  "AP LLS",
  "GS LREL",
  "GL LYON",
  "SB MACC",
  "GS MATH",
  "ED MATH",
  "SC MATH",
  "GL MATH",
  "SB MBAN",
  "GS MDES",
  "GS MECH",
  "LE MECH",
  "SB MFIN",
  "SB MGMT",
  "SB MINE",
  "AP MIST",
  "SB MKTG",
  "SB MMAI",
  "AP MODR",
  "GL MODR",
  "SB MSTM",
  "ED MUSI",
  "FA MUSI",
  "GS MUSI",
  "SC NATS",
  "GL NATS",
  "HH NRSC",
  "SC NRSC",
  "HH NURS",
  "GS NURS",
  "SB OMIS",
  "ED ORCO",
  "SB ORGS",
  "GS OVGS",
  "SB OVGS",
  "GS PACC",
  "FA PANF",
  "GS PCS",
  "AP PERS",
  "ED PHED",
  "GS PHIL",
  "GL PHIL",
  "ED PHIL",
  "AP PHIL",
  "GS PHYS",
  "SC PHYS",
  "ED PHYS",
  "GL PHYS",
  "GS PIA",
  "HH PKIN",
  "SB PLCY",
  "GS POLS",
  "AP POLS",
  "GL POLS",
  "ED POLS",
  "AP POR",
  "GS PPAL",
  "AP PPAS",
  "SB PROP",
  "AP PRWR",
  "GS PSYC",
  "HH PSYC",
  "GL PSYC",
  "SB PUBL",
  "ED RELS",
  "ED SCIE",
  "GS SELA",
  "SC SENE",
  "SB SGMT",
  "ED SLGS",
  "GS SLST",
  "GL SOCI",
  "GS SOCI",
  "AP SOCI",
  "SB SOCM",
  "AP SOSC",
  "ED SOSC",
  "GL SOSC",
  "AP SOWK",
  "GS SOWK",
  "AP SP",
  "GL SP",
  "GS SPTH",
  "SC STS",
  "GS STS",
  "AP SWAH",
  "GL SXST",
  "AP SXST",
  "ED TECH",
  "LE TECL",
  "AP TESL",
  "GS THEA",
  "FA THEA",
  "GS THST",
  "ED TLSE",
  "GL TRAN",
  "GS TRAN",
  "GS TRAS",
  "GS TXLW",
  "ED VISA",
  "GS VISA",
  "FA VISA",
  "AP WKLS",
  "GS WMST",
  "AP WRIT",
  "FA YSDN"
];

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
    // // for (var element in scrape) {
    // //   String title = element['title'];
    // //   title = title.trim();
    // //   String url = element['attributes']['href'];
    // //   url = url.trim();
    // //   print(title);
    // //   print(url);
    // // }
    // print(news[0].url);
  }

  return news;
}

Future<Null> postYorkCourses() async {
  for (var course in courses) {
    var v = course.split(' ');
    var faculty = v[0];
    var subject = v[1];
    scrapeCoursesYork(faculty, subject);
  }
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
