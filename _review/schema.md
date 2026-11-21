# Front: таблицы по направлениям

## 1. Анализ закупки продукции

Закупка — это документ `DocumentTypeID = 4` и строки `bm_StorageOperations` с `OperationID = 1`. Одного `OperationID = 1` мало: в нём 22 016 строк, из них 11 358 — закупки (тип 4), а 10 658 — положительные строки товарных чеков (тип 6). Закупок: 3 175 документов, 21 поставщик, 19 657 112,54.

### 1.1. Основные таблицы

bm_JournalBarnetDocs (шапки документов)
- ID: ключ документа (388235)
- Period: дата документа (2020-11-11)
- DocumentTypeID: тип, 4 = поступление (4)
- Amount: сумма документа (892.77)
- PersonID: автор (897)
- CompanyID: своя организация (6)

bm_StorageOperations (строки поступления)
- ID: ключ строки (4780421)
- DocumentID: документ (388235)
- OperationID: 1 = приход (1)
- ProductID: товар (4368)
- VendorID: поставщик (200)
- StorageID: склад (41)
- Price: цена (323.00)
- Count: количество (2.7640)
- Amount: сумма (892.77)
- Rest: остаток после операции, не заполнен (0)
- BatchID: партия, партий нет (0)

bm_JournalTypeDocuments (типы документов)
- ID: ключ (4)
- Description: название (Поступление продуктов)
- JournalID: журнал (3)

bm_StorageOperationsType (виды операций)
- ID: ключ (1)
- Description: название (Поступление)
- Factor: знак для остатка (1)

### 1.2. Связанные таблицы

product (номенклатура)
- id: ключ (4368)
- productid: внешний код (1137721)
- description: название (Грудинка (Бекон))
- flaging: тип, 1 = ингредиент (1)
- CategoryID: категория (203)

category (категории)
- id: ключ (203)
- description: название (Мясная продукция)
- ParentID: родитель (199)

vendors (поставщики)
- id: ключ (200)
- firstname: название (ООО "Элит Трейд")
- clientgroup: группа (31)
- INN: ИНН (NULL)

storages (склады)
- id: ключ (41)
- description: название (Склад)
- ResponsibleID: ответственный (897)
- CompanyID: организация (6)

bm_Companies (свои организации)
- ID: ключ (6)
- CompanyName: название (ИП Лукьянова Анастасия Игоревна)
- ShortName: краткое (Пиzzбург)
- INN: ИНН (380122679974)

personnel (автор документа)
- personid: ключ (897)
- firstname: имя (Администратор Barnet)
- securityaccess: роль (9)

pricelist (история цен)
- id: ключ (113681)
- productid: товар (4544)
- basecost: цена (140.00)
- groupid: тип цены (2)
- vendorid: поставщик, не заполнен (NULL)

bm_Contracts (договоры поставки, таблица пустая)
- ID: ключ договора
- VendorID: поставщик
- CompanyID: организация
- ContractNumber: номер договора
- Period: дата договора

## 2. Анализ продажи товара

Продажа — строки `journal` с `transtype = 101`: 119 367 строк в 43 043 чеках на 42 306 984,17. Плюс `transtype = 111` — весовые продажи: 2 673 строки, 1 977 чеков, 570 935,05. Строки `status = 1` — сторно, 31 строка на 8 729,00, в итог чека не входят. Итог по чекам (`transtype = 501`): 42 869 802,22.

### 2.1. Основные таблицы

journal (строки чеков)
- transnumber: ключ строки (1951181)
- posid: терминал (5)
- transtype: тип, 101 = продажа (101)
- receiptn: номер чека (50672281)
- dater: дата (2023-12-06 13:58:26)
- id: код товара (7239833)
- description: название (Соус Барбекю)
- categoryid: категория (178)
- price: цена (50.00)
- quantity: количество (1.000)
- amount: сумма (50.00)
- loginid: кассир (906)
- flagrefund: возврат (0)
- status: 1 = сторно (0)

bm_Journal_Details (расшифровка чека по ингредиентам)
- SourceID: транзакция (1675591)
- ProductID: ингредиент (4407)
- BludoID: блюдо (4451)
- Count: количество (0.4000)
- StorageID: склад (41)
- TicketNumber: чек (14740696)

bm_JournalBarnetDocs (шапка товарного чека, тип 6)
- ID: ключ (415426)
- DocumentTypeID: тип (6)
- TicketNumber: номер чека (14740696)
- Amount: сумма (1240.00)
- PersonID: сотрудник (906)

bm_StorageOperations (списание ингредиентов по чекам)
- DocumentID: документ (415426)
- OperationID: 2 = списание (2)
- ProductID: ингредиент (4345)
- Count: количество, отрицательное (-0.1300)
- Amount: сумма, отрицательная (-19.50)

transtype (типы транзакций)
- transtypeid: ключ (101)
- description: название (PLU Sales)
- PreviewGroupType: группа (POS)

В базе встречаются 101 продажа, 111 списание по себестоимости, 211 наличные, 216 безнал, 301 вход, 386 и 387 начало и конец работы, 501 итог чека.

### 2.2. Связанные таблицы

product (товар)
- productid: код (7239833)
- description: название (Соус Барбекю)
- CategoryID: категория (178)

category (категория позиции)
- id: ключ (178)
- description: название (Соусы)
- ParentID: родитель (147)

clients (клиенты и карты)
- id: ключ (109)
- clientid: код (1234)
- clientgroup: группа (37)
- lastname: название (Самовывоз)
- bonus: бонус (10.000)

clientgroup (группы клиентов)
- clientgroupid: ключ (37)
- description: название (Дсконт карты)
- discount: скидка (5.000)

paymenttype (типы оплаты)
- paymenttypeid: ключ (211)
- description: название (Наличные)
- paymentflag: признак (1)

personnel (кассир)
- personid: ключ (906)
- lastname: фамилия (Доставка)
- firstname: имя (Доставка)
- securityaccess: роль (3)

bm_BonusHistory (бонусы по чекам)
- PersonID: сотрудник (906)
- ClientID: клиент (255)
- TicketNumber: чек (59368651)
- BonusValue: сумма (884.00)

## 3. Анализ взаимоотношений с поставщиками

Основа — `vendors` и закупочные строки `bm_StorageOperations` с `VendorID`. В справочнике 63 поставщика, в закупках участвует 21, ИНН заполнен у 5. Договоры и платежи в базе не ведутся.

### 3.1. Основные таблицы

vendors (справочник поставщиков)
- id: ключ (211)
- clientid: код (Пятая Армия)
- clientgroup: группа (32)
- firstname: название (Пятая Армия)
- INN: ИНН (NULL)
- KPP: КПП (NULL)
- cityid: город (NULL)

bm_StorageOperations (закупочные строки)
- VendorID: поставщик (200)
- DocumentID: документ (388235)
- ProductID: товар (4368)
- Price: цена (323.00)
- Count: количество (2.7640)
- Amount: сумма (892.77)

Все 11 358 закупочных строк имеют заполненный `VendorID`, все находят поставщика.

bm_JournalBarnetDocs (документ закупки)
- ID: ключ (388235)
- Period: дата (2020-11-11)
- DocumentTypeID: тип (4)
- Amount: сумма (892.77)

bm_Contracts (договоры с поставщиками, таблица пустая)
- ID: ключ договора
- VendorID: поставщик
- ContractNumber: номер договора
- Period: дата договора

pricelist (цены)
- productid: товар (4544)
- basecost: цена (140.00)
- vendorid: поставщик (NULL)

### 3.2. Связанные таблицы

vendorgroup (группы поставщиков)
- vendorgroupid: ключ (31)
- description: название (Поставщики)

Всего две записи: 31 и 32.

city (город поставщика)
- cityid: ключ (4)
- name: название (Иркутск)

В справочнике 17 городов, у поставщиков `cityid` заполнен у 3 из 63.

bm_Companies (своя организация)
- ID: ключ (6)
- CompanyName: название (ИП Лукьянова Анастасия Игоревна)
- INN: ИНН (380122679974)

bm_PaymentOperations (платежи по договорам, таблица пустая)
- ID: ключ платежа
- PaymentTypeID: тип оплаты
- ContractID: договор
- Amount: сумма

bm_CashOperations (кассовые расчёты с поставщиком, таблица пустая)
- ID: ключ операции
- VendorID: поставщик
- ContractID: договор
- Amount: сумма

## 4. Анализ работы персонала

Сотрудники — в `personnel` (109 записей). Смены — события `journal` с `transtype` 386 (начало) и 387 (окончание): 11 532 события у 35 сотрудников. Продажи к сотруднику не привязаны: все 119 367 строк имеют `loginid = 906`.

### 4.1. Основные таблицы

personnel (справочник сотрудников)
- personid: ключ (898)
- lastname: фамилия (Безик)
- firstname: имя (Татьяна)
- middlename: отчество (Сергеевна)
- securityaccess: роль (9)
- deleteflag: признак удаления (1)
- percent: максимальная скидка (10.000)

journal (события работы)
- transtype: 386 начало, 387 окончание, 301 вход (386)
- dater: дата (2023-12-06 09:50:30)
- loginid: сотрудник (1066)
- transnumber: транзакция (1951154)
- posid: терминал (5)

bm_JournalBarnetDocs (документы сотрудника)
- ID: ключ (388235)
- PersonID: автор (897)
- DocumentTypeID: тип (4)
- Period: дата (2020-11-11)

bm_BonusHistory (бонусы и привязка чека к сотруднику)
- PersonID: сотрудник (906)
- TicketNumber: чек (59368651)
- BonusValue: сумма (884.00)
- IsCalc: признак (0)

### 4.2. Связанные таблицы

securityaccess (роли доступа)
- securityaccessid: ключ (2)
- description: название (Clerk)

В справочнике 4 роли: 2, 3, 4, 9.

bm_JournalSessions (журнал действий)
- ID: ключ (1)
- Type: тип (Система)
- Message: текст (Произведена очистка журнала системных сообщений.)
- DateAdd: дата (2019-10-10 10:09:48)
- PersonID: сотрудник (897)

bm_PersonnelSecurity (права сотрудника)
- PersonID: сотрудник (906)
- ObjectID: объект (36)
- IsUse: признак (1)

bm_SecurityObjects (объекты прав)
- ID: ключ (1)
- ParentSystem: система (Manager)
- SecurityGroup: группа (Прочее)
- ObjectName: объект (dlgProperties)

bm_WorkHours (таблица пустая)
- ID: ключ записи
- ShiftID: смена
- PersonID: сотрудник
- SystemPeriod: системный период
- ManualPeriod: ручной период

bm_ShiftsOperations (одна старая запись)
- ID: ключ (65)
- ShiftNumber: номер (1)
- DateAdd: дата (2015-07-14)
- PersonalID: сотрудник (0)

## 5. Анализ остатков

Остатки ведутся регистром `bm_StorageOperations`. `Count` хранится со знаком: приход положительный, списание отрицательное, поэтому остаток — это `SUM(Count)` по товару. Готовых срезов нет: `closingcount`, `onhand`, `stock`, `stockbp`, `storagesonhand` пустые.

### 5.1. Основные таблицы

bm_StorageOperations (регистр движений)
- DocumentID: документ (388235)
- OperationID: 1 приход, 2 списание (1)
- ProductID: товар (4368)
- StorageID: склад (41)
- Count: количество, со знаком (2.7640)
- Price: цена (323.00)
- Amount: сумма (892.77)
- Rest: остаток после операции, везде 0
- BatchID: партия, везде 0
- ReasonID: причина списания (0)

Всего 1 031 198 движений: 22 016 приходов по 232 товарам и 1 009 182 списания по 293 товарам.

bm_StorageOperationsType (виды операций)
- ID: ключ (2)
- Description: название (Списание)
- Factor: знак (-1)

bm_JournalBarnetDocs (документы движения)
- ID: ключ (465974)
- DocumentTypeID: 4 поступление, 5 списание, 6 товарный чек, 8 инвентаризация
- Period: дата (2023-12-03)
- Amount: сумма (948.75)

bm_JournalTypeDocuments (типы документов)
- ID: ключ (5)
- Description: название (Списание продуктов)

bm_StorageOperations_Table (списания с себестоимостью)
- DocumentID: документ (465974)
- ProductID: товар (4382)
- PriceCost: себестоимость (275.30)
- Count: количество (-0.0500)
- Amount: сумма (-13.7700)
- ReasonID: причина (122)

### 5.2. Связанные таблицы

product (номенклатура, поля остатков не заполнены)
- id: ключ (4337)
- productid: код (1204073)
- description: название (Бананы)
- flaging: тип (1)
- onhand: остаток (NULL)
- closingcount: остаток на дату (0.000)

category (категория товара)
- id: ключ (149)
- description: название (Склад)
- ParentID: родитель (0)

bm_ReasonDebit (причины списания)
- ID: ключ (1)
- ParentID: родитель (0)
- Description: название (Порча продукта)

В справочнике 47 причин, у части есть родитель: 7 — «Сотрудникам по заработную плату», 16 — вложенная.

bm_Journal_Details (фактический расход ингредиентов)
- ProductID: ингредиент (4407)
- BludoID: блюдо (4451)
- Count: количество (0.4000)
- SourceID: транзакция (1675591)
- StorageID: склад (41)

## 6. Что пустое

- Договоры и платежи: `bm_Contracts`, `bm_PaymentOperations`, `bm_CashOperations`.
- Остатки: `closingcount`, `onhand`, `stock`, `stockbp`, `storagesonhand`.
- Персонал: `bm_WorkHours`.

Таблицы существуют и связаны с остальными, но данных в них нет.
