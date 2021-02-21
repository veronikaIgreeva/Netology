#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jan 26 20:35:40 2020

@author: igreevaveronika
"""

import requests
from bs4 import BeautifulSoup as bs
from selenium import webdriver
import time
import csv


headers = {'accept': '*/*',
          'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36'}

base_url = 'https://hh.ru/search/vacancy?st=searchVacancy&text=data&area=113&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=&items_on_page=100&no_magic=false&L_save_area=true&page=0'



def hh_parse(base_url, headers):
    jobs = []
    urls = []
    urls.append(base_url)
    session = requests.Session()
    request = session.get(base_url, headers=headers)
    if request.status_code == 200:
        soup = bs(request.content, 'lxml')
        try:
            pagination = soup.find_all('a', attrs={'data-qa': 'pager-page'})
            count = int(pagination[-1].text)
            for i in range(count):
                url = f'https://hh.ru/search/vacancy?st=searchVacancy&text=data&area=113&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=&items_on_page=100&no_magic=false&L_save_area=true&page={i}'
                if url not in urls:
                    urls.append(url)
                
            
            
        except:
            pass
    
    for url in urls:
        request = session.get(url, headers=headers)
        soup = bs(request.content, 'lxml')
        divs = soup.find_all('div', attrs={'data-qa': ['vacancy-serp__vacancy', 'vacancy-serp__vacancy vacancy-serp__vacancy_premium']})
        for div in divs:
            try:
                title = div.find('a', attrs={'data-qa': 'vacancy-serp__vacancy-title'}).text
                href = div.find('a', attrs={'data-qa': 'vacancy-serp__vacancy-title'})['href']
                company = div.find('a', attrs={'data-qa': 'vacancy-serp__vacancy-employer'}).text
                text1 = div.find('div', attrs={'data-qa': 'vacancy-serp__vacancy_snippet_responsibility'}).text
                text2 = div.find('div', attrs={'data-qa': 'vacancy-serp__vacancy_snippet_requirement'}).text
                content = text1 + ' ' + text2
                jobs.append({
                    'title': title,
                    'href': href,
                    'company': company,
                    'content': content
                })
            except:
                pass
        
        print(len(jobs))
        
        
    else:
        print('ERROR or Done' + str(request.status_code))
        
    return jobs

def files_writer(jobs):
    with open('parsed_jobs.csv', 'a') as file:
        a_pen = csv.writer(file)
        a_pen.writerow(('Название вакансии', 'URL', 'Название компании', 'Описание'))
        for job in jobs:
            a_pen.writerow((job['title'], job['href'], job['company'], job['content']))

        
        
jobs = hh_parse(base_url, headers)
files_writer(jobs)