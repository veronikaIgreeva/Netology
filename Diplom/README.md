Дипломный проект в Нетологии

Описание парсинга данных с Head Hunter при помощи Scrapy.

Я использовала в работе Anaconda-Navigator, установив библиотеку scrapy. При помощи  терминала с этой библиотеки создала проект hh в этом проекте несколько пауков по шаблону crawl


Пауки:

1. scrapy genspider -t crawl analytic hh.ru/search/vacancy?st=searchVacancy&text= %D0%B0%D0%BD%D0%B0%D0%BB%D0%B8%D1%82%D0%B8%D0%BA&search_field=name&area=113&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=&items_on_page=50&no_magic=true&L_save_area=true 
Показывает все вакансии по поиску слова «Аналитик»

2. scrapy genspider -t crawl bigdata hh.ru/search/vacancy?area=113&clusters=true&enable_snippets=true&items_on_page=50&no_magic=true&text=big+data&from=SIMILAR_QUERY
Показывает все вакансии по поиску слова «bigdata»

3. scrapy genspider -t crawl data_vacancies hh.ru/search/vacancy?L_is_autosearch=false&area=113&clusters=true&enable_snippets=true&items_on_page=50&no_magic=true&search_field=name&search_field=description&text=data&page=0
Показывает все вакансии по поиску слова «data»

4. scrapy genspider -t crawl dataanalyst  hh.ru/search/vacancy?st=searchVacancy&text=Data+analyst&area=113&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=&items_on_page=50&no_magic=true&L_save_area=true&from=suggest_post
Показывает все вакансии по поиску слов « Data+analyst»

5. scrapy genspider -t crawl datamining  hh.ru/search/vacancy?st=searchVacancy&text=Data+mining&area=113&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=&items_on_page=50&no_magic=true&L_save_area=true&from=suggest_post
Показывает все вакансии по поиску слов « Data+mining»

6. scrapy genspider -t crawl datascience hh.ru/search/vacancy?st=searchVacancy&text=Data+science&search_field=name&area=113&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=&items_on_page=50&no_magic=true&L_save_area=true&from=suggest_post
Показывает все вакансии по поиску слов «Data+science»

7. scrapy genspider -t crawl datascientist hh.ru/search/vacancy?st=searchVacancy&text=Data+scientist&area=113&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=&items_on_page=50&no_magic=true&L_save_area=true&from=suggest_post
Показывает все вакансии по поиску слов «Data+scientist»

Далее я воспользовалась VisualStudio, чтобы обработать пауков и задать вытаскиваемые значения.


После успешной обработки получила scv файлы, которые затем просто склеила в один большой файл. Аналогично спарсила резюме.

Сложности:
Их на самом деле куча. 
- Вполне допускаю то, что у меня в итоге получились задвоенные вакансии. Решить проблему хочу методами Excel, там есть такие полезные функции.
- Некоторые ссылки выглядят очень странно, например нормальные ссылки выглядят так: https://hh.ru/vacancy/34622764, и получены несколько длинных ссылок такого вида: https://hh.ru/vacancy/34183545?query=big%20data. Решить проблему также планирую методами Excel.
- Не во всех вакансиях отдельно прописаны необходимые скиллы, некоторые придется сложно и долго выуживать из текстового описания вакансий. Думаю решить эту проблему методами pandas и Excel.
- Зарплата прописана тоже не совсем удобно:
з/п не указана
от ,170 000, ,руб., до вычета налогов
от ,130 000, до ,160 000, ,руб., на руки
Придется решать какое значение или какой порог брать для анализа зарплаты. Придется изначально убирать лишние символы либо в pandas, либо Excel. По выбору значения для анализа вопрос пока открыт.
- поле Описание вакансии (description) пришлось разбить на три. Все из-за разных типов объявлений. XPath в некоторых объявлениях отличается.
