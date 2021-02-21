# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule


class VacansySpider(CrawlSpider):
    name = 'bigdata'
    allowed_domains = ['hh.ru']
    
    user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36'

    def start_requests(self):
        yield scrapy.Request(url='https://hh.ru/search/vacancy?area=113&clusters=true&enable_snippets=true&items_on_page=50&no_magic=true&text=big+data&from=SIMILAR_QUERY', headers={
            'User-Agent': self.user_agent
        })

    rules = (
        Rule(LinkExtractor(restrict_xpaths="//a[@class = 'bloko-link HH-LinkModifier']"), callback='parse_item', follow=True, process_request='set_user_agent'),
        Rule(LinkExtractor(restrict_xpaths="(//a[@class = 'bloko-button HH-Pager-Controls-Next HH-Pager-Control']"), process_request='set_user_agent')
    )

    def set_user_agent(self, request):
        request.headers['User-Agent'] = self.user_agent
        return request

    def parse_item(self, response):
        skills = []
        skills_all = response.xpath("//span[@class = 'Bloko-TagList-Text']")
        for skill in skills_all:
            i = skill.xpath(".//text()").get()
            skills.append(i)
        
        yield {
            'title': response.xpath("//h1/text()").get(),
            'experience': response.xpath("//span[@data-qa = 'vacancy-experience']/text()").get(),
            'type_job': response.xpath("//p[@data-qa = 'vacancy-view-employment-mode']/text()").get(),
            'time_job': response.xpath("//p[@data-qa = 'vacancy-view-employment-mode']/span/text()").get(),
            'company_name': response.xpath("//a[@data-qa='vacancy-company-name']/span/text()").getall(),
            'skills': skills,
            'vacancy_datecity': response.xpath("//p[@class = 'vacancy-creation-time']/text()").getall(),
            'salary': response.xpath("//p[@class = 'vacancy-salary']/span/text()").getall(),
            'vacansy_url': response.url,
            'description': response.xpath("//div[@class='g-user-content']/p/text()").getall(),
            'description_branded': response.xpath("//div[@class = 'vacancy-branded-user-content']/p/text()").getall(),
            'description_branded1': response.xpath("//div[@class = 'vacancy-branded-user-content']/ul/text()").getall()
        }