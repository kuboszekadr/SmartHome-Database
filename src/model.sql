--
-- PostgreSQL database cluster dump
--

-- Started on 2021-04-22 12:33:14

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md53175bce1d3201d16594cebf9d7eb3f9d';






--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.11 (Debian 11.11-0+deb10u1)
-- Dumped by pg_dump version 13.2

-- Started on 2021-04-22 12:33:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Completed on 2021-04-22 12:33:15

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.11 (Debian 11.11-0+deb10u1)
-- Dumped by pg_dump version 13.2

-- Started on 2021-04-22 12:33:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 16386)
-- Name: pgagent; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgagent;


ALTER SCHEMA pgagent OWNER TO postgres;

--
-- TOC entry 3025 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA pgagent; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA pgagent IS 'pgAgent system tables';


--
-- TOC entry 2 (class 3079 OID 16387)
-- Name: pgagent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgagent WITH SCHEMA pgagent;


--
-- TOC entry 3026 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgagent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgagent IS 'A PostgreSQL job scheduler';


-- Completed on 2021-04-22 12:33:15

--
-- PostgreSQL database dump complete
--

--
-- Database "smart_home" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.11 (Debian 11.11-0+deb10u1)
-- Dumped by pg_dump version 13.2

-- Started on 2021-04-22 12:33:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3118 (class 1262 OID 16558)
-- Name: smart_home; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE smart_home WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C.UTF-8';


ALTER DATABASE smart_home OWNER TO postgres;

\connect smart_home

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 11 (class 2615 OID 16559)
-- Name: front_end; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA front_end;


ALTER SCHEMA front_end OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 16560)
-- Name: pgagent; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgagent;


ALTER SCHEMA pgagent OWNER TO postgres;

--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA pgagent; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA pgagent IS 'pgAgent system tables';


--
-- TOC entry 10 (class 2615 OID 16561)
-- Name: stg; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stg;


ALTER SCHEMA stg OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 16562)
-- Name: pgagent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgagent WITH SCHEMA pgagent;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgagent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgagent IS 'A PostgreSQL job scheduler';


--
-- TOC entry 250 (class 1255 OID 16733)
-- Name: p_reading_populate(); Type: PROCEDURE; Schema: front_end; Owner: postgres
--

CREATE PROCEDURE front_end.p_reading_populate()
    LANGUAGE plpgsql
    AS $$
declare 
	v_cut_off timestamp;
begin
 	v_cut_off := to_timestamp(
			(extract(epoch from date_trunc('minute', now()) ) / 300)::int * 300)
	;

drop table if exists tmp_reading;
create temporary table tmp_reading as 
select * 
from public.reading
where reading_timestamp >= v_cut_off - interval '1' day
;

drop table if exists tmp_scope;
create temporary table tmp_scope as
select
	device_id,
	sensor_id,
	measure_id,
	
	sensor_label,
	measure_name,
		
	generate_series(v_cut_off - interval '1 day', v_cut_off, interval '5 minutes') - interval '5 minutes' as dt_from,
	generate_series(v_cut_off - interval '1 day', v_cut_off, interval '5 minutes') - interval '1 second' as dt_to
from public.device_sensor_measure
;

truncate table front_end.reading;
insert into front_end.reading
select 
	s.device_id,
	s.sensor_id,
	s.measure_id,
	
	s.sensor_label,
	s.measure_name,
	
	to_char(s.dt_from, 'YYYY-MM-DD HH24:mi') as reading_timestamp_label,
	
	round(avg(r.reading_value), 2) as reading_value,
	count(r.reading_value) as reading_count,
	
	now() as last_update
from 
		tmp_scope as s
	left join
		tmp_reading as r on
			s.device_id = r.device_id
			and s.sensor_id = r.sensor_id
			and s.measure_id = r.measure_id 
			and r.reading_timestamp between s.dt_from and s.dt_to
group by 
	1, 2, 3, 
	4, 5,
	6
order by 1, 2, 3, 6
;
end;
$$;


ALTER PROCEDURE front_end.p_reading_populate() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16734)
-- Name: populate_reading(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.populate_reading()
    LANGUAGE sql
    AS $$
insert into public.reading (sensor_id, reading_value, measure_id, reading_timestamp, device_id)
select distinct
    s.*
from 
        stg.reading as s
    left join 
        public.reading as p using 
            (sensor_id, reading_value, measure_id, reading_timestamp, device_id)
where p.reading_id is null
;

truncate stg.reading;
$$;


ALTER PROCEDURE public.populate_reading() OWNER TO postgres;

SET default_tablespace = '';

--
-- TOC entry 215 (class 1259 OID 16735)
-- Name: reading; Type: TABLE; Schema: front_end; Owner: postgres
--

CREATE TABLE front_end.reading (
    device_id integer,
    sensor_id bigint,
    measure_id bigint,
    sensor_label text,
    measure_name text,
    reading_timestamp_label character varying(20),
    reading_value numeric(5,3),
    reading_count bigint,
    last_update timestamp without time zone DEFAULT now()
);


ALTER TABLE front_end.reading OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16742)
-- Name: d_device; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_device (
    device_id integer NOT NULL,
    device_name text,
    date_ins timestamp without time zone DEFAULT now()
);


ALTER TABLE public.d_device OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16749)
-- Name: d_device2sensor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_device2sensor (
    id integer NOT NULL,
    device_id integer,
    sensor_id integer,
    device_sensor_id integer,
    sensor_label text,
    date_ins timestamp without time zone DEFAULT now()
);


ALTER TABLE public.d_device2sensor OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16756)
-- Name: d_device_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.d_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.d_device_id_seq OWNER TO postgres;

--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 218
-- Name: d_device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.d_device_id_seq OWNED BY public.d_device.device_id;


--
-- TOC entry 219 (class 1259 OID 16758)
-- Name: d_measure; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_measure (
    measure_id integer NOT NULL,
    measure_name text,
    date_ins timestamp without time zone DEFAULT now()
);


ALTER TABLE public.d_measure OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16765)
-- Name: d_program; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_program (
    id integer NOT NULL,
    name character(255),
    date_ins timestamp without time zone DEFAULT now()
);


ALTER TABLE public.d_program OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16769)
-- Name: d_program_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.d_program_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.d_program_id_seq OWNER TO postgres;

--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 221
-- Name: d_program_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.d_program_id_seq OWNED BY public.d_program.id;


--
-- TOC entry 222 (class 1259 OID 16771)
-- Name: d_sensor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_sensor (
    sensor_id integer NOT NULL,
    sensor_name text NOT NULL,
    measure_id integer[],
    date_ins timestamp without time zone DEFAULT now()
);


ALTER TABLE public.d_sensor OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16778)
-- Name: d_sensor_sensor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.d_sensor_sensor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.d_sensor_sensor_id_seq OWNER TO postgres;

--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 223
-- Name: d_sensor_sensor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.d_sensor_sensor_id_seq OWNED BY public.d_sensor.sensor_id;


--
-- TOC entry 224 (class 1259 OID 16780)
-- Name: device_sensor; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.device_sensor AS
 SELECT d.device_id,
    d.device_name,
    s.sensor_id,
    s.sensor_name,
    sd.sensor_label,
    s.measure_id
   FROM ((public.d_device d
     JOIN public.d_device2sensor sd ON ((d.device_id = sd.device_id)))
     JOIN public.d_sensor s ON ((sd.sensor_id = s.sensor_id)));


ALTER TABLE public.device_sensor OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16784)
-- Name: device_sensor_measure; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.device_sensor_measure AS
 WITH cte AS (
         SELECT d.device_id,
            d.device_name,
            s.sensor_id,
            s.sensor_name,
            sd.sensor_label,
            unnest(s.measure_id) AS measure_id
           FROM ((public.d_device d
             JOIN public.d_device2sensor sd USING (device_id))
             JOIN public.d_sensor s USING (sensor_id))
        )
 SELECT c.device_id,
    c.device_name,
    c.sensor_id,
    c.sensor_name,
    c.sensor_label,
    c.measure_id,
    m.measure_name
   FROM (cte c
     JOIN public.d_measure m USING (measure_id));


ALTER TABLE public.device_sensor_measure OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16789)
-- Name: program_runtime; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.program_runtime (
    id integer NOT NULL,
    program_id integer,
    execution_id bigint,
    step integer,
    is_active boolean,
    execution_timestamp timestamp without time zone,
    date_ins timestamp without time zone DEFAULT now()
);


ALTER TABLE public.program_runtime OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16793)
-- Name: program_runtime_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.program_runtime_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_runtime_id_seq OWNER TO postgres;

--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 227
-- Name: program_runtime_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.program_runtime_id_seq OWNED BY public.program_runtime.id;


--
-- TOC entry 228 (class 1259 OID 16795)
-- Name: reading; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reading (
    reading_id integer NOT NULL,
    sensor_id bigint,
    reading_value numeric(10,3),
    measure_id bigint,
    reading_timestamp timestamp without time zone,
    date_ins timestamp without time zone DEFAULT now(),
    device_id integer
);


ALTER TABLE public.reading OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16799)
-- Name: reading_reading_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reading_reading_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reading_reading_id_seq OWNER TO postgres;

--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 229
-- Name: reading_reading_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reading_reading_id_seq OWNED BY public.reading.reading_id;


--
-- TOC entry 230 (class 1259 OID 16801)
-- Name: sensor2device_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sensor2device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor2device_id_seq OWNER TO postgres;

--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 230
-- Name: sensor2device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sensor2device_id_seq OWNED BY public.d_device2sensor.id;


--
-- TOC entry 231 (class 1259 OID 16803)
-- Name: reading; Type: TABLE; Schema: stg; Owner: postgres
--

CREATE TABLE stg.reading (
    sensor_id bigint,
    reading_value numeric(10,3),
    measure_id bigint,
    reading_timestamp timestamp without time zone,
    device_id integer
);


ALTER TABLE stg.reading OWNER TO postgres;

--
-- TOC entry 2943 (class 2604 OID 16806)
-- Name: d_device device_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_device ALTER COLUMN device_id SET DEFAULT nextval('public.d_device_id_seq'::regclass);


--
-- TOC entry 2945 (class 2604 OID 16807)
-- Name: d_device2sensor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_device2sensor ALTER COLUMN id SET DEFAULT nextval('public.sensor2device_id_seq'::regclass);


--
-- TOC entry 2948 (class 2604 OID 16808)
-- Name: d_program id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_program ALTER COLUMN id SET DEFAULT nextval('public.d_program_id_seq'::regclass);


--
-- TOC entry 2950 (class 2604 OID 16809)
-- Name: d_sensor sensor_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_sensor ALTER COLUMN sensor_id SET DEFAULT nextval('public.d_sensor_sensor_id_seq'::regclass);


--
-- TOC entry 2952 (class 2604 OID 16810)
-- Name: program_runtime id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.program_runtime ALTER COLUMN id SET DEFAULT nextval('public.program_runtime_id_seq'::regclass);


--
-- TOC entry 2954 (class 2604 OID 16811)
-- Name: reading reading_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading ALTER COLUMN reading_id SET DEFAULT nextval('public.reading_reading_id_seq'::regclass);


--
-- TOC entry 2981 (class 2606 OID 16813)
-- Name: d_device2sensor d_device2sensor_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_device2sensor
    ADD CONSTRAINT d_device2sensor_unique UNIQUE (device_id, device_sensor_id);


--
-- TOC entry 2979 (class 2606 OID 16815)
-- Name: d_device d_device_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_device
    ADD CONSTRAINT d_device_pkey PRIMARY KEY (device_id);


--
-- TOC entry 2985 (class 2606 OID 16817)
-- Name: d_measure d_measure_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_measure
    ADD CONSTRAINT d_measure_pkey PRIMARY KEY (measure_id);


--
-- TOC entry 2987 (class 2606 OID 16819)
-- Name: d_sensor d_sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_sensor
    ADD CONSTRAINT d_sensor_pkey PRIMARY KEY (sensor_id);


--
-- TOC entry 2983 (class 2606 OID 16821)
-- Name: d_device2sensor sensor2device_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_device2sensor
    ADD CONSTRAINT sensor2device_pkey PRIMARY KEY (id);


--
-- TOC entry 2988 (class 2606 OID 16822)
-- Name: d_device2sensor sensor2device_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_device2sensor
    ADD CONSTRAINT sensor2device_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.d_device(device_id);


--
-- TOC entry 2989 (class 2606 OID 16827)
-- Name: d_device2sensor sensor2device_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_device2sensor
    ADD CONSTRAINT sensor2device_sensor_id_fkey FOREIGN KEY (sensor_id) REFERENCES public.d_sensor(sensor_id);


-- Completed on 2021-04-22 12:33:16

--
-- PostgreSQL database dump complete
--

-- Completed on 2021-04-22 12:33:16

--
-- PostgreSQL database cluster dump complete
--

