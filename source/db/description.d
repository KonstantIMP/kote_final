module db.description;

import db.uda;

@Table("Тип номенклатуры")
struct NomenclatureType
{
    static const Entry name_type = {
        name:"Наименование",
        type:EntryType.String,
        primary: true
    }; @(_e(name_type)) string name;
}

@Table("Станция")
struct Station
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.String,
        regexp: `^\w{4,4}\b$`,
        max_length: 4,
        primary: true
    }; @(_e(number_type)) string number;

    static const Entry name_type = {
        name:"Наименование",
        type:EntryType.String
    }; @(_e(name_type)) string name;

    static const Entry addr_type = {
        name:"Адрес",
        type:EntryType.String,
        max_length: 256
    }; @(_e(addr_type)) string address;

    static const Entry ind_type = {
        name: "Индекс",
        type: EntryType.String,
        regexp: `^\w{6,6}\b$`,
        max_length: 6
    }; @(_e(ind_type)) string ind;

    static const Entry state_type = {
        name:"Состояние",
        type:EntryType.String,
        max_length: 256
    }; @(_e(state_type)) string state;
}

@Table("Приостановка работы")
struct StationPause
{
    static const Entry id_type = {
        name: "ID",
        type: EntryType.String,
        regexp: `^\w{4,4}\b$`,
        max_length: 4
    }; @(_e(id_type)) string id;

    static const Entry station_type = {
        name: "Станция",
        type: EntryType.Link,
        max_length: 4,
        link_address: "Station:number"
    }; @(_e(station_type)) string station;

    static const Entry pdate_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(pdate_type)) string pdate;

    static const Entry reason_type = {
        name: "Причина",
        type: EntryType.String,
        max_length: 256
    }; @(_e(station_type)) string reason;
}

@Table("Закрытие станции")
struct StationStop
{
    static const Entry id_type = {
        name: "ID",
        type: EntryType.String,
        regexp: `^\w{4,4}\b$`,
        max_length: 4
    }; @(_e(id_type)) string id;

    static const Entry station_type = {
        name: "Станция",
        type: EntryType.Link,
        max_length: 4,
        link_address: "Station:number"
    }; @(_e(station_type)) string station;

    static const Entry sdate_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(sdate_type)) string sdate;

    static const Entry reason_type = {
        name: "Причина",
        type: EntryType.String,
        max_length: 256
    }; @(_e(reason_type)) string reason;
}

@Table("Номенклатура")
struct Nomenclature
{
    static const Entry article_type = {
        name: "Артикул",
        type: EntryType.String,
        regexp: `^\w{6,6}\b$`,
        max_length: 6,
        primary: true
    }; @(_e(article_type)) string article;

    static const Entry name_type = {
        name:"Наименование",
        type:EntryType.String
    }; @(_e(name_type)) string name;

    static const Entry type_type = {
        name: "Тип номенклатуры",
        type: EntryType.Link,
        link_address: "NomenclatureType:name"
    }; @(_e(type_type)) string type;

    static const Entry usage_type = {
        name: "Используется",
        type: EntryType.Boolean
    }; @(_e(usage_type)) bool usage;

    static const Entry sdate_type = {
        name: "Дата ввода",
        type: EntryType.Date
    }; @(_e(sdate_type)) string sdate;

    static const Entry fdate_type = {
        name: "Дата вывода",
        type: EntryType.Date
    }; @(_e(fdate_type)) string fdate;
}

@Table("Ввод в эксплуатацию")
struct Input
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.Integer,
        primary: true,
        autoincrement: true
    }; @(_e(number_type)) int number;

    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry article_type = {
        name: "Артикул",
        type: EntryType.String,
        regexp: `^\w{6,6}\b$`,
        max_length: 6
    }; @(_e(article_type)) string article;

    static const Entry name_type = {
        name:"Наименование",
        type:EntryType.String
    }; @(_e(name_type)) string name;

    static const Entry type_type = {
        name: "Тип номенклатуры",
        type: EntryType.Link,
        link_address: "NomenclatureType:name"
    }; @(_e(type_type)) string type;
}

@Table("Вывод из эксплуатацию")
struct Output
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.Integer,
        primary: true,
        autoincrement: true
    }; @(_e(number_type)) int number;

    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry article_type = {
        name: "Артикул",
        type: EntryType.Link,
        regexp: `^\w{6,6}\b$`,
        max_length: 6,
        link_address: "Nomenclature:article"
    }; @(_e(article_type)) string article;

    static const Entry type_type = {
        name: "Тип номенклатуры",
        type: EntryType.Link,
        link_address: "NomenclatureType:name"
    }; @(_e(type_type)) string type;
}

@Table("Перемещения")
struct Moves
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.Integer,
        primary: true,
        autoincrement: true
    }; @(_e(number_type)) int number;

    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry article_type = {
        name: "Артикул",
        type: EntryType.Link,
        regexp: `^\w{6,6}\b$`,
        max_length: 6,
        link_address: "Nomenclature:article"
    }; @(_e(article_type)) string article;

    static const Entry reason_type = {
        name: "Инициатор",
        type: EntryType.Enumeration,
        enum_values: ["Сотрудник", "Клиент"]
    }; @(_e(reason_type)) string reason;

    static const Entry reason_name_type = {
        name: "ФИО инициатора",
        type: EntryType.String
    }; @(_e(reason_name_type)) string reason_name;

    static const Entry nstation_type = {
        name: "Новая станция",
        type: EntryType.Link,
        link_address: "Station:number"
    }; @(_e(nstation_type)) string nstation;
}

@Table("Прайс")
struct Price
{
    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry type_type = {
        name: "Тип номенклатуры",
        type: EntryType.Link,
        link_address: "NomenclatureType:name"
    }; @(_e(type_type)) string type;

    static const Entry price_type = {
        name: "Новая цена",
        type: EntryType.Integer
    }; @(_e(price_type)) int price;
}

@Table("Начало аренды")
struct Start
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.Integer,
        primary: true,
        autoincrement: true
    }; @(_e(number_type)) int number;

    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry stime_type = {
        name: "Время",
        type: EntryType.Time
    }; @(_e(stime_type)) string stime;

    static const Entry user_type = {
        name: "Пользователь",
        type: EntryType.Link,
        link_address: "User:phone"
    }; @(_e(user_type)) string user;

    static const Entry article_type = {
        name: "Артикул",
        type: EntryType.Link,
        regexp: `^\w{6,6}\b$`,
        max_length: 6,
        link_address: "Nomenclature:article"
    }; @(_e(article_type)) string article;
}

@Table("Окончание аренды")
struct Finish
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.Integer,
        primary: true,
        autoincrement: true
    }; @(_e(number_type)) int number;

    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry stime_type = {
        name: "Время",
        type: EntryType.Time
    }; @(_e(stime_type)) string stime;

    static const Entry user_type = {
        name: "Пользователь",
        type: EntryType.Link,
        link_address: "User:phone"
    }; @(_e(user_type)) string user;

    static const Entry article_type = {
        name: "Артикул",
        type: EntryType.Link,
        regexp: `^\w{6,6}\b$`,
        max_length: 6,
        link_address: "Nomenclature:article"
    }; @(_e(article_type)) string article;
}

@Table("Оплата")
struct Payment
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.Integer,
        primary: true,
        autoincrement: true
    }; @(_e(number_type)) int number;

    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry stime_type = {
        name: "Время",
        type: EntryType.Time
    }; @(_e(stime_type)) string stime;

    static const Entry user_type = {
        name: "Пользователь",
        type: EntryType.Link,
        link_address: "User:phone"
    }; @(_e(user_type)) string user;

    static const Entry article_type = {
        name: "Артикул",
        type: EntryType.Link,
        regexp: `^\w{6,6}\b$`,
        max_length: 6,
        link_address: "Nomenclature:article"
    }; @(_e(article_type)) string article;

    static const Entry ut_type = {
        name: "Время использования",
        type: EntryType.Integer
    }; @(_e(ut_type)) int ut;

    static const Entry amount_type = {
        name: "Сумма оплаты",
        type: EntryType.Integer
    }; @(_e(amount_type)) int amount;
}

@Table("Начисление бонусов")
struct Bonuses
{
    static const Entry number_type = {
        name: "Номер",
        type: EntryType.Integer,
        primary: true,
        autoincrement: true
    }; @(_e(number_type)) int number;

    static const Entry date_type = {
        name: "Дата",
        type: EntryType.Date
    }; @(_e(date_type)) string date;

    static const Entry stime_type = {
        name: "Время",
        type: EntryType.Time
    }; @(_e(stime_type)) string stime;

    static const Entry user_type = {
        name: "Пользователь",
        type: EntryType.Link,
        link_address: "User:phone"
    }; @(_e(user_type)) string user;

    static const Entry reason_type = {
        name: "Причина",
        type: EntryType.Enumeration,
        enum_values: ["За аренду", "За ивент", "По решению сотрудника"]
    }; @(_e(reason_type)) string reason;

    static const Entry desc_type = {
        name: "Описание",
        type: EntryType.String
    }; @(_e(desc_type)) string desc;

    static const Entry amount_type = {
        name: "Количество бонусов",
        type: EntryType.Integer
    }; @(_e(amount_type)) int amount;
}

@Table("Пользователь")
struct User
{
    static const Entry name_type = {
        name: "Имя",
        type: EntryType.String
    }; @(_e(name_type)) string name;

    static const Entry surname_type = {
        name: "Отчество",
        type: EntryType.String
    }; @(_e(surname_type)) string surname;

    static const Entry lastname_type = {
        name: "Фамилия",
        type: EntryType.String
    }; @(_e(lastname_type)) string lastname;

    static const Entry phone_type = {
        name: "Телефон",
        type: EntryType.Phone,
        primary: true
    }; @(_e(phone_type)) string phone;

    static const Entry email_type = {
        name: "EMail",
        type: EntryType.Email
    }; @(_e(email_type)) string email;

    static const Entry hb_type = {
        name: "День рождения",
        type: EntryType.Date
    }; @(_e(hb_type)) string hb;

    static const Entry status_type = {
        name: "Статус",
        EntryType.Enumeration,
        enum_values: ["Новый", "Обычный", "Регулярный", "Постоянный", "VIP"]
    }; @(_e(status_type)) string status;
}

@Table("Профиль")
struct Profile
{
    static const Entry login_type = {
        name: "Логин",
        type: EntryType.String,
        primary: true
    }; @(_e(login_type)) string login;

    static const Entry name_type = {
        name: "Имя",
        type: EntryType.String
    }; @(_e(name_type)) string name = "";

    static const Entry surname_type = {
        name: "Отчество",
        type: EntryType.String,
        required: false
    }; @(_e(surname_type)) string surname = "";

    static const Entry lastname_type = {
        name: "Фамилия",
        type: EntryType.String
    }; @(_e(lastname_type)) string lastname = "";

    static const Entry phone_type = {
        name: "Телефон",
        type: EntryType.Phone
    }; @(_e(phone_type)) string phone;

    static const Entry email_type = {
        name: "EMail",
        type: EntryType.Email
    }; @(_e(email_type)) string email;

    static const Entry psswd_type = {
        name: "Пароль",
        type: EntryType.String
    }; @(_e(psswd_type)) string psswd;

    static const Entry sending_type = {
        name: "Рассылка",
        type: EntryType.Boolean
    }; @(_e(sending_type)) bool sending = true;

    static const Entry balance_type = {
        name: "Баланс",
        type: EntryType.Integer
    }; @(_e(balance_type)) int balance = 0;

    static const Entry premium_type = {
        name: "Premium",
        type: EntryType.Boolean
    }; @(_e(premium_type)) bool premium = false;

    static const Entry sex_type = {
        name: "Пол",
        type: EntryType.Enumeration,
        enum_values: ["Не определен", "Мужской", "Женский"]
    }; @(_e(sex_type)) string sex = "Не определен";

    static const Entry hb_type = {
        name: "День рождения",
        type: EntryType.Date
    }; @(_e(hb_type)) string hb = "";

    static const Entry aphone_type = {
        name: "Дополнительный телефон",
        type: EntryType.Phone,
        required: false
    }; @(_e(aphone_type)) string aphone = "";

    static const Entry aemail_type = {
        name: "дополнительный EMail",
        type: EntryType.Email,
        required: false
    }; @(_e(aemail_type)) string aemail = "";

    static const Entry addr_type = {
        name: "Адрес",
        type: EntryType.String,
        required: false
    }; @(_e(addr_type)) string addr = "";

    static const Entry sale_type = {
        name: "Скидка",
        type: EntryType.Integer
    }; @(_e(sale_type)) int sale = 0;
}
