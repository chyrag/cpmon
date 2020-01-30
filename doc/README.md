# Career Page Monitor

## Objective

The idea is to monitor open positions at different companies on behalf of the
partners. The partners would mean recruitment agencies who would like to use the
loopcv platform to search for jobs for their clients.

## User Workflow

Once the partner login to the platform, they shall see the list of companies
they have expressed interest in. Each of those company listings will take them
to the page with the job openings in that company. The same page has a text
field which they can use to add new companies to their list. An AJAX query or
similar will help with auto completion of the company names from the list of
existing companies. Upon submitting the new company name, the company name will
get added to the list of companies subscribed to by the partner, and the page
will be refreshed.

Upon clicking on the company name from the list of companies seen in Workflow 1,
the user shall see the job titles and the date of posting for openings in that
company. Upon clicking the job titles, they would see the job description.

TBD: further actions on the job description page.

## Services
1. Company Service: Company DB microservice which is basic CRUD on companies, to
   be used by partners.
2. Career Page Service: Service to google the company and find the career page
   link and add it to the company DB. The Company service would notify the
   Career Page service using the messaging broker, whenever a new company is
   added.
3. Job Poller Service: Service to periodically go over the company career page
   links, poll for openings, and add the scraped job openings into jobsDB.

## Company Service

### Supported API Endpoints
1. `GET /company/id/xxxxxx`
   Returns the company with the id xxxxxx.
   Payload: None
   Example Response:
   ```
    {
        "id": "xxxxxx",
        "name": "Acme Networks",
    }
   ```

2. `GET /company/name/xxx`
   Return the list of companies that start with xxx.
   Payload: None
   Example Response:
   ```
   [
       {
        "id": "xxxxxx",
        "name": "Acme Networks"
       },
       {
        "id": "xxxxxx",
        "name": "Ace Technologies"
       },
       {
        "id": "xxxxxx",
        "name": "Acer Limited"
       }
   ]
   ```

3. `POST /company`
   Add new company name to the company DB.
   Payload:
   ```
   {
       "name": "Name of the Company"
   }
   ```
   Example Response:
   ```
   {
       "id": "xxxxxx",
       "name": "Acme Networks",
   }
   ```


4. `DELETE /company`
   Delete the company
   Payload:
   ```
   {
       "id": "xxxxxx"
   }
   ```
   Example Response: None (HTTP Status will indicate status).


5. `GET /company/all`
   Returns list of all companies with their information.
   Payload: None
   Example Response:
   ```
   [
       {
        "id": "xxxxxx",
        "name": "Acme Networks"
       },
       {
        "id": "xxxxxx",
        "name": "Ace Technologies"
       },
       {
        "id": "xxxxxx",
        "name": "Acer Limited"
       },
       ...
   ]
   ```

## Career Page Service

### Supported API Endpoints
    None

### Functionality

Career Page Service shall subscribe to a topic on RabbitMQ, Kafka or some such
message broker. The message from Company service will trigger a scraper job that
would google for the company name (is there a better place to find company
website - crunchbase?), find the company website, and after that page for
careers on their website. After getting all of those data, the service will add
these details to its own DB, which would be different from the company service
DB to avoid race conditions between multiple services writing to the same DB.


## Job Poller Service

Job Poller Service runs multiple poller threads periodically, to search for jobs
listed on the career pages of the companies stored in Career Page Service. The
main thread has to schedule the poller threads. The number of poller threads
should be configurable on the fly through a REST API endpoint. By default, the
poller could start 4 or 6 threads.

### Supported API Endpoints
1. `GET /poller/status`
   Payload: none
   Example Response: ```TBD`
