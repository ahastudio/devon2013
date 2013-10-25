express = require('express')
Crawler = require('crawler').Crawler

createProgramDetailCrawler = (programs) ->
  new Crawler
    callback: (error, result, $) ->
      url = result.uri.match(/\/program\/(.*)\//)[1]
      program = programs.findByUrl(url)
      imageUrl = $('#post-thumbnail img').attr('src')
      program.image_url = imageUrl

createProgramListCrawler = (programs, detailCrawler) ->
  new Crawler
    callback: (error, result, $) ->
      $('#content article').each ->
        article = $(this)
        realUrl = article.find('h2 a').attr('href')
        url = realUrl.match(/\/program\/(.*)\//)[1]
        title = article.find('h2').text()
        categories = $.makeArray article.find('.category-index a').map ->
          $(this).attr('href').match(/\/category\/(.*)\//)[1]
        imageUrl = article.find('img.attachment-thumbnail').attr('src')
        programs.push
          url: url
          title: title
          categories: categories
          thumbnail_url: imageUrl
        detailCrawler.queue(realUrl)

fetchPrograms = (programs) ->
  categories = [
    'booth', 'meetup', 'daum', 'gurutalk', 'codelab', 'event'
  ]
  detailCrawler = createProgramDetailCrawler(programs)
  crawler = createProgramListCrawler(programs, detailCrawler)
  for category in categories
    url = "http://devon.daum.net/2013/program/category/#{category}"
    crawler.queue(url)

programs = []
programs.__proto__.findByUrl = (url) ->
  for program in this
    return program if program.url is url
  null

fetchPrograms(programs)

app = express()

app.get '/programs.json', (req, res) ->
  res.send(programs)

app.listen(3000)
console.log('Listening on port 3000...')
