/*Вопрос 3.1. В каких городах больше одного аэропорта?
 * Решение: Считаем через счетчик count, выводим названия городов, в которых больше одного аэропорта
 * через группировку group by city having count (airport_code) > 1
*/
select count (airport_code), city 
from bookings.airports
group by city 
having count (airport_code) > 1


/*Вопрос 3.2. Были ли брони, по которым не совершались перелеты?
 * Задача решена двумя способами.
 * Способ 1. В условии не указано, что рейс уже совершен. 
 * Объединяем таблицы boarding, tickets и bookings. При объединении boarding и tickets использовался right join,
 * чтобы сделать главной таблицу tickets, так как интересуют значения NULL в boarding.
 * После завершения объединений, выводим условие where boarding_no is null, чтобы получить рейсы, в которых имеется номер брони,
 * но отсутствует boarding_no. Ответ: да, были.
 */
select bp.boarding_no, b.book_ref 
from bookings.boarding_passes bp
	right join bookings.tickets t
	using (ticket_no)
		join bookings.bookings b
		using (book_ref)
where boarding_no is null


/* Вопрос 3.2. Были ли брони, по которым не совершались перелеты?
 * Способ 2. Условие, что рейс уже совершен или отменен.
 * Аналогично способу первому объединяем таблицы bookings, tickets, boarding_passes и ticket_flights.
 * Везде при объединении использовался left join, так как в этом решении таблица bookings используется как главная,
 * к ней присоединяются все остальные таблицы (со значениями NULL в том числе).
 * После присоединения всех таблиц задаем условие where bp.boarding_no is null
	and f.status in ('Departed', 'Arrived', 'Cancelled'). Ответ: нет, не было.
 */
select b.book_ref, t.ticket_no, bp.boarding_no, f.flight_id, f.status 
from bookings.bookings b
	left join bookings.tickets t
	using (book_ref)
		left join bookings.boarding_passes bp
		using (ticket_no)
			left join bookings.ticket_flights tf
			using (ticket_no)
				left join bookings.flights f
				on f.flight_id = tf.flight_id
where bp.boarding_no is null
and f.status in ('Departed', 'Arrived', 'Cancelled')

	
/* Вопрос 3.3. В каких аэропортах(!) есть рейсы, которые обслуживаются самолетами с максимальной дальностью перелетов?
 * Решение: Для решения задачи объединяем таблицы airports, routes и aircrafts, выбираем в отображаемых столбцах 
 * уникальные значения airport_code, в условии прописываем, что значение столбца "range" из таблицы aircrafts
 * является максимальным значением (выбор осуществляется через подзапрос).
 */
select distinct (a.airport_code), a.airport_name, 
ac.aircraft_code, ac.model, ac."range"
from bookings.airports a
	join bookings.routes r
	on r.departure_airport = a.airport_code
	or r.arrival_airport = a.airport_code
		join bookings.aircrafts ac
		using (aircraft_code)
where ac."range" in (
	select max ("range") 
	from bookings.aircrafts
	)


/* Вопрос 5*. Между какими городами(!) нет прямых рейсов?
(* необязательные задания повышенной сложности)
 * Для решения задачи я использовала подзапрос и декартово произведение.
 * Также мной использовались две таблицы:  airports (для получения всех городов)
 * и routes (для получения всех городов, между которым есть рейсы).
 * Выбираем все столбцы из подзапроса: (Подзапрос:
 * задаем стобец, в котором объединяем названия городов отправления и прибытия (все города) из таблицы airports с алиасом а,
 * объединяем таблицу airports с самой собой с алиасом b через cross join,
 * задаем условие, что город из таблицы а не равен городу из таблицы b (исключаем города, 
 * в которых бы совпадали город отправления и город назначения), 
 * из полученных данных при помощи except вычтем данные ниже:
 * объединенные названия городов вылета и прибытия из таблицы routes)
 * Для удобства отсортируем полученные данные. 
 */
select * from ( 
	select a.city|| ' ' ||b.city as city_no_flights 
	from bookings.airports a 
		cross join bookings.airports b 
		where a.city != b.city 
	except 
	select departure_city|| ' ' ||arrival_city 
	from bookings.routes) c 
order by city_no_flights 


/* Анализ БД.
 * Задача 1. Рассчитываем пассажировместимость каждого типа самолета в парке.
 * Объединяем таблицы seats и aircrafts. 
 * При помощи оконной функции рассчитываем количество мест для каждого типа самолета.
 * Для удобства чтения сортируем по количеству мест в самолете.
 */
select distinct (aircraft_code), a.model,
	count (s.seat_no) over (partition by aircraft_code) as count_seats
from bookings.seats s
	join bookings.aircrafts a
	using (aircraft_code)
order by count_seats desc


/* Задача 2.1. Выведем самые пассажиро-загруженные полеты, между какими городами они совершались и даты вылета.
 * Дату вылета использую для того, чтобы вывести и те самолеты, которые еще в воздухе.
 * Использую все рейсы, даже на которые имеется бронь, так как меня интересуют все популярные маршруты.
 * Выбираю отображаемые столбцы, причем меня интересуют уникальные полеты
 * и счетчиком count считаю количество купленных билетов на конкретный flight_id,
 * объединяю таблицы ticket_flights, flights_v и aircraft_code
 * сортирую по count_tickets 
 */
select distinct (flight_id), 
f.departure_city|| ' '|| f.arrival_city as cities, f.actual_departure, 
a.aircraft_code, a.model, 
count (ticket_no) over (partition by flight_id) as count_tickets
from bookings.ticket_flights
	join bookings.flights_v f
	using (flight_id)
		join bookings.aircrafts a
		using (aircraft_code) 
order by count_tickets desc

/* Задача 2.2. Выведем самые пассажиро-загруженные рейсы (больше 5000 человек), между какими городами они совершались.
 * Здесь уже меня не интересуют конкретные полеты, а регулярные рейсы и количество пассажиров.
 * Так как данные о полетах в базе за месяц до даты и месяц после, то мы получим в итоге количество пассажиров за месяц плюс забронированные полеты.
 * Здесь из предыдущего запроса я убрала лишний столбец с датой вылета 
 * и использовала его в качестве источника данных, то есть сформировала подзапрос и задала условие, 
 * выводить данные, в которых счетчик билетов имеет значение более 5000, отсортировала по возрастанию.
 */
select * from (
	select distinct (flight_no), f.departure_city|| ' '|| f.arrival_city as cities, 
	a.aircraft_code, a.model, 
	count (ticket_no) over (partition by flight_no) as count_tickets
	from bookings.ticket_flights
		join bookings.flights_v f
		using (flight_id)
			join bookings.aircrafts a
			using (aircraft_code) 
	) z
where count_tickets > 5000
order by count_tickets desc

/* Задача 3.1. Выведем полеты, между какими городами они осуществляются, модель самолета, осуществляющая рейс, количество мест в самолете
 * и процент загрузки самолета пассажирами (свыше 95%).
 * Выведем столбцы с flight_id, городами, между которым осуществлялся рейс, количеством мест в самолете, количеством купленных билетов и 
 * процент загрузки по формуле (round((z.count_tickets * 100 / z.aircraft_seats), 2).
 * В подзапросе укажем источник данных - уникальный flight_id, счетчик купленных билето, сгруппированных при помощи оконной функции по flight_id,
 * при помощи оператора case я изменила значение aircraft_code на числовое (количество мест в самолете),
 * согласно решению задачи № 1. Сделано это было потому, что БД слишком долго обрабатывает запрос с присоединением 
 * таблицы seats. Объединяем таблицы ticket_flights, flights_v и aircrafts,
 * задаем условие where z.count_tickets * 100 / z.aircraft_seats > 95 и группируем по убыванию.
 * Условие where z.count_tickets * 100 / z.aircraft_seats > 95 можно было бы упростить через еще один подзапрос, но выбор пал в пользу практичности.
 */
select flight_id, z.cities, z.model, z.aircraft_seats, z.count_tickets,
round ((z.count_tickets * 100 / z.aircraft_seats), 2) as percent_seats
from (	
	select distinct (flight_id), f.departure_city||' '||f.arrival_city as cities, a.model, 
		case 
		when a.aircraft_code = '773' then 402
		when a.aircraft_code = '763' then 222
		when a.aircraft_code = '321' then 170
		when a.aircraft_code = '320' then 140
		when a.aircraft_code = '733' then 130
		when a.aircraft_code = '319' then 116
		when a.aircraft_code = 'SU9' then 97
		when a.aircraft_code = 'CR2' then 50
		when a.aircraft_code = 'CN1' then 12
		end as aircraft_seats,
	count (ticket_no) over (partition by flight_id) as count_tickets
	from bookings.ticket_flights
		join bookings.flights_v f
		using (flight_id)
			join bookings.aircrafts a
			using (aircraft_code) 
	) z
where z.count_tickets * 100 / z.aircraft_seats > 95
order by model desc

/* Задача 3.2 Посчитаем на базе предыдущего запроса сколько рейсов выполнено каждым типом самолетов.
  */
select model, count (flight_id) as count_flights from (
select flight_id, z.cities, z.model, z.aircraft_seats, z.count_tickets,
round ((z.count_tickets * 100 / z.aircraft_seats), 2) as percent_seats
from (	
	select distinct (flight_id), f.departure_city||' '||f.arrival_city as cities, a.model, 
		case 
		when a.aircraft_code = '773' then 402
		when a.aircraft_code = '763' then 222
		when a.aircraft_code = '321' then 170
		when a.aircraft_code = '320' then 140
		when a.aircraft_code = '733' then 130
		when a.aircraft_code = '319' then 116
		when a.aircraft_code = 'SU9' then 97
		when a.aircraft_code = 'CR2' then 50
		when a.aircraft_code = 'CN1' then 12
		end as aircraft_seats,
	count (ticket_no) over (partition by flight_id) as count_tickets
	from bookings.ticket_flights
		join bookings.flights_v f
		using (flight_id)
			join bookings.aircrafts a
			using (aircraft_code) 
	) z
where z.count_tickets * 100 / z.aircraft_seats > 95
order by model desc) y
group by model
order by count_flights 


/* Задача 4.1. Выведем самые прибыльные рейсы (больше 100 000 000 рублей за месяц), между какими городами они осуществлялись, 
 * общую прибыль по каждому рейсу и количество пассажиров. Учитываем все рейсы, даже пока не совершенные, то есть с доходом будущего периода.
 * Выводим столбцы с номером рейса и городами вылета и прибытия, отдельно выводим счетчик суммы из стоимости билетов
 * и количество проданных билетов. 
 * Объединяем таблицы flights_v, ticket_flights, группируем данные по столбцу flight_no, 
 * где счетчик суммы имеет значение больше 100 000 000 рублей. Сортируем по сумме.
 */
select flight_no, departure_city, arrival_city,  
sum (t.amount) as total_amount, 
count (t.ticket_no) as total_number_of_passenger
from bookings.flights_v f
	join bookings.ticket_flights t
	using (flight_id)
		group by flight_no, departure_city, arrival_city
		having sum (t.amount) > 100000000
order by total_amount desc

/*Задача 4.2 Выведем самые прибыльные рейсы (больше 100 000 000 рублей за месяц), между какими городами они осуществлялись, 
 * общую прибыль по каждому рейсу и количество пассажиров. 
 * Учитываем только уже совершенные рейсы, таким образом мы исключаем отсюда доход будущего периода.
 * Решение точно такое же, просто добавляем условие, что статус полетов "Вылетел" и "Прибыл".
 */
select flight_no, departure_city, arrival_city,  
sum (t.amount) as total_amount, 
count (t.ticket_no) as total_number_of_passenger
from bookings.flights_v f
	join bookings.ticket_flights t
	using (flight_id)
		where f.status in ('Departed', 'Arrived')
			group by flight_no, departure_city, arrival_city
			having sum (t.amount) > 100000000
order by total_amount desc


/* Задача 5.1. Выведем самые неприбыльные, возможно убыточные рейсы с загрузкой меньше 100 пассажиров за месяц и выручкой меньше 5 000 000 рублей,
 *  среднюю стоимость билета, количество купленных билетов за месяц и общую сумму купленных билетов, 
 * причем выберем статусы полетов "В полете", "Прибыл", "Отменен" и "Открыт для регистрации",
 * стоит также учесть, что самолет с кодом CN1 (Cessna 208 Caravan) имеет вместимость 12 человек, поэтому исключим его из запроса.
 * Выводим столбцы с номером рейса, средней стоимостью билета, округленной до двух десятых, сумму купленных билетов
 * и количество купленных билетов из объединенных таблиц ticket_flights, flights_v и aircrafts. 
 * При помощи WHERE отфильтровываем самолеты с кодом CN1 (Cessna 208 Caravan) и выбираем статусы ('Departed', 'Arrived', 'Delayed', 'Cancelled')
 * Все это оборачиваем в подзапрос, чтобы вывести новый фильтр where count_ticket < 100 и sum_amount < 5000000. Сортируем по сумме.
 */
select * from (
	select f.flight_no, f.departure_city|| ' '||f.arrival_city as cities, 
	round (avg (amount), 2) as avg_amount, 
	sum (amount) as sum_amount, 
	count (ticket_no) as count_ticket
	from bookings.ticket_flights
		join bookings.flights_v f
		using (flight_id)
			join bookings.aircrafts a
			using (aircraft_code)
	where a.aircraft_code not in ('CN1')
	and f.status in ('Departed', 'Arrived', 'Delayed', 'Cancelled')
		group by f.flight_no, f.departure_city, f.arrival_city
	) z
where count_ticket < 100
and sum_amount < 5000000
order by sum_amount

/* Задача 5.2 Выведем информацию по аномальному рейсу.
 * 
 */
select flight_id, flight_no, aircraft_code, actual_departure 
from bookings.flights_v
where flight_no = 'PG0587'
and actual_departure is not null
order by actual_departure

--и обратный рейс
select flight_id, flight_no, aircraft_code, actual_departure 
from bookings.flights_v
where flight_no = 'PG0587'
and actual_departure is not null
order by actual_departure


/* Задача 6. Вывести минимальную стоимоть билета для каждого класса обслуживания.
 * Результат выведем из таблицы ticket_flights при помощи функций min (amount) и max (amount). 
 * Сгруппируем по классу обслуживания.
 */
select fare_conditions, 
min (amount) as min_amount 
from bookings.ticket_flights
group by fare_conditions

