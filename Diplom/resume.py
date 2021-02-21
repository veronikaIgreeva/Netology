# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule


class ResumeSpider(CrawlSpider):
    name = 'resume'
    allowed_domains = ['hh.ru']
    
    user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36'

    def start_requests(self):
        yield scrapy.Request(url='https://hh.ru/search/resume?L_is_autosearch=false&area=1&clusters=true&exp_period=all_time&logic=normal&no_magic=false&order_by=relevance&pos=full_text&text=Data&search_period=30&order_by=relevance', headers={
            'User-Agent': self.user_agent
        })


    rules = (
        Rule(LinkExtractor(restrict_xpaths="//a[@class='resume-search-item__name HH-VisitedResume-Href HH-LinkModifier']"), callback='parse_item', follow=True, process_request='set_user_agent'),
        Rule(LinkExtractor(restrict_xpaths="//a[@class = 'bloko-button HH-Pager-Controls-Next HH-Pager-Control']"), process_request='set_user_agent')
    )
    def set_user_agent(self, request):
        request.headers['User-Agent'] = self.user_agent
        return request

    def parse_item(self, response):
        skills = []
        skills_all = response.xpath("//span[@data-qa='bloko-tag__text']")
        for skill in skills_all:
            i = skill.xpath(".//text()").get()
            skills.append(i)
        yield {
            'vacancy_name': response.xpath("//span[@class='resume-block__title-text']/text()").getall(),
            'gender': response.xpath("//span[@data-qa = 'resume-personal-gender']/text()").get(),
            'age': response.xpath("//span[@data-qa='resume-personal-age']/text()").get(),
            'city': response.xpath("//span[@data-qa='resume-personal-address']/text()").get(),
            'skills': skills,
            'experience': response.xpath("(//span[@class='resume-block__title-text resume-block__title-text_sub'])[1]/text()").getall(),
            'last_job': response.xpath("//a[@class='bloko-link bloko-link_list']/text()").get(),
            'resume_url': response.url
        }
