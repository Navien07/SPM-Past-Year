-- ============================================================
-- SPM AI — one-shot Supabase setup (schema + seed)
-- Paste this whole file into Supabase -> SQL Editor -> Run.
-- Fresh project: creates 9 tables + seeds 8 subjects, 36 topics,
-- a Sejarah trial paper, demo student & sample attempts.
-- ============================================================

SET search_path TO public;

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateTable
CREATE TABLE public."Subject" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "nameEn" TEXT,
    "code" TEXT NOT NULL,
    "color" TEXT NOT NULL DEFAULT '#3470f4',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Subject_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Topic" (
    "id" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "form" INTEGER NOT NULL,
    "chapter" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "subtopics" TEXT NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Topic_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Paper" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "paperType" TEXT NOT NULL,
    "year" INTEGER NOT NULL,
    "state" TEXT,
    "paperNumber" INTEGER NOT NULL DEFAULT 1,
    "fileUrl" TEXT,
    "fileName" TEXT,
    "rawText" TEXT,
    "markingScheme" TEXT,
    "rubric" TEXT,
    "status" TEXT NOT NULL DEFAULT 'uploaded',
    "categorizedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Paper_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Question" (
    "id" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "topicId" TEXT,
    "paperId" TEXT,
    "paperNumber" INTEGER NOT NULL DEFAULT 1,
    "questionType" TEXT NOT NULL,
    "number" TEXT,
    "stem" TEXT NOT NULL,
    "options" TEXT NOT NULL DEFAULT '[]',
    "answer" TEXT,
    "markingScheme" TEXT,
    "rubric" TEXT,
    "marks" INTEGER NOT NULL DEFAULT 1,
    "isKbat" BOOLEAN NOT NULL DEFAULT false,
    "subtopic" TEXT,
    "year" INTEGER,
    "source" TEXT NOT NULL DEFAULT 'past_paper',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Question_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Student" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "form" INTEGER NOT NULL DEFAULT 5,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Student_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Attempt" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "score" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "maxScore" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "band" TEXT,
    "isCorrect" BOOLEAN,
    "feedback" TEXT,
    "gradedByAi" BOOLEAN NOT NULL DEFAULT false,
    "timeSpentSec" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Attempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."StudySession" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "subjectId" TEXT,
    "durationSec" INTEGER NOT NULL DEFAULT 0,
    "questionsDone" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudySession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."GeneratedQuestion" (
    "id" TEXT NOT NULL,
    "topicId" TEXT NOT NULL,
    "questionType" TEXT NOT NULL,
    "stem" TEXT NOT NULL,
    "options" TEXT NOT NULL DEFAULT '[]',
    "answer" TEXT,
    "markingScheme" TEXT,
    "rubric" TEXT,
    "marks" INTEGER NOT NULL DEFAULT 1,
    "isKbat" BOOLEAN NOT NULL DEFAULT true,
    "basedOn" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GeneratedQuestion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."MockPaper" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "paperNumber" INTEGER NOT NULL DEFAULT 1,
    "questionIds" TEXT NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MockPaper_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Subject_name_key" ON public."Subject"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Subject_code_key" ON public."Subject"("code");

-- CreateIndex
CREATE INDEX "Topic_subjectId_idx" ON public."Topic"("subjectId");

-- CreateIndex
CREATE UNIQUE INDEX "Topic_subjectId_form_chapter_key" ON public."Topic"("subjectId", "form", "chapter");

-- CreateIndex
CREATE INDEX "Paper_subjectId_idx" ON public."Paper"("subjectId");

-- CreateIndex
CREATE INDEX "Paper_paperType_idx" ON public."Paper"("paperType");

-- CreateIndex
CREATE INDEX "Question_subjectId_idx" ON public."Question"("subjectId");

-- CreateIndex
CREATE INDEX "Question_topicId_idx" ON public."Question"("topicId");

-- CreateIndex
CREATE INDEX "Question_year_idx" ON public."Question"("year");

-- CreateIndex
CREATE UNIQUE INDEX "Student_email_key" ON public."Student"("email");

-- CreateIndex
CREATE INDEX "Attempt_studentId_idx" ON public."Attempt"("studentId");

-- CreateIndex
CREATE INDEX "Attempt_questionId_idx" ON public."Attempt"("questionId");

-- CreateIndex
CREATE INDEX "StudySession_studentId_idx" ON public."StudySession"("studentId");

-- CreateIndex
CREATE INDEX "GeneratedQuestion_topicId_idx" ON public."GeneratedQuestion"("topicId");

-- AddForeignKey
ALTER TABLE public."Topic" ADD CONSTRAINT "Topic_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Paper" ADD CONSTRAINT "Paper_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Question" ADD CONSTRAINT "Question_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Question" ADD CONSTRAINT "Question_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Question" ADD CONSTRAINT "Question_paperId_fkey" FOREIGN KEY ("paperId") REFERENCES public."Paper"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Attempt" ADD CONSTRAINT "Attempt_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Attempt" ADD CONSTRAINT "Attempt_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."StudySession" ADD CONSTRAINT "StudySession_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."GeneratedQuestion" ADD CONSTRAINT "GeneratedQuestion_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- ===================== SEED DATA ============================

--
-- PostgreSQL database dump
--


-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: Subject; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5qyl00007dwnv5y7uo6a', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-17 07:59:33.31');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5qzm000n7dwn9b1wr4vk', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-17 07:59:33.346');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5qzw000w7dwnlom4v2kw', 'English', 'English', 'ENG', '#2563eb', '2026-06-17 07:59:33.357');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5r0800157dwnfc5q7eux', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-17 07:59:33.369');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5r0j001e7dwnxd0f36k7', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-17 07:59:33.379');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5r0r001l7dwn73whw3zw', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-17 07:59:33.387');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5r14001u7dwne6ghselr', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-17 07:59:33.401');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhs5r1d00217dwnzbe3kfy8', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-17 07:59:33.409');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqhs5r1n00297dwn0jkw659p', 'Sejarah Kertas 1 & 2 — Percubaan SPM 2025 (Negeri)', 'cmqhs5qyl00007dwnv5y7uo6a', 'trial', 2025, 'Selangor', 2, NULL, NULL, 'Kertas percubaan SPM Sejarah 2025 — soalan telah dikategorikan.', 'Skema pemarkahan rasmi disertakan untuk setiap soalan.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks yang jelas"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}],"bands":[{"band":"Cemerlang","range":"16-20","descriptor":"Fakta tepat, huraian mendalam, nilai diterapkan"},{"band":"Baik","range":"11-15","descriptor":"Fakta mencukupi dengan sedikit huraian"},{"band":"Memuaskan","range":"6-10","descriptor":"Fakta asas sahaja"},{"band":"Lemah","range":"0-5","descriptor":"Fakta tidak relevan / terhad"}]}', 'categorized', '2026-06-17 07:59:33.418', '2026-06-17 07:59:33.42');


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qyr00027dwn4koe72t4', 'cmqhs5qyl00007dwnv5y7uo6a', 4, 1, 'Kemunculan Tamadun Awal Manusia', '["Mesopotamia","Mesir Purba","Indus","Hwang Ho"]', '2026-06-17 07:59:33.315');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qyv00047dwn6j7x77tt', 'cmqhs5qyl00007dwnv5y7uo6a', 4, 2, 'Peningkatan Tamadun', '["Yunani","Rom","India","China"]', '2026-06-17 07:59:33.319');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qyy00067dwnx1whl4x4', 'cmqhs5qyl00007dwnv5y7uo6a', 4, 3, 'Tamadun Awal di Asia Tenggara', '["Kerajaan agraria","Kerajaan maritim"]', '2026-06-17 07:59:33.322');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qz000087dwn671mn5kn', 'cmqhs5qyl00007dwnv5y7uo6a', 4, 4, 'Kemunculan Tamadun Islam di Makkah', '["Masyarakat Arab Jahiliah","Riwayat Nabi Muhammad SAW"]', '2026-06-17 07:59:33.324');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qz2000a7dwny9o725ct', 'cmqhs5qyl00007dwnv5y7uo6a', 4, 5, 'Kerajaan Islam di Madinah', '["Piagam Madinah","Perjanjian Hudaibiyah"]', '2026-06-17 07:59:33.327');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qz5000c7dwnvqziihao', 'cmqhs5qyl00007dwnv5y7uo6a', 4, 9, 'Perkembangan di Eropah', '["Renaissance","Reformation","Revolusi Perindustrian"]', '2026-06-17 07:59:33.329');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qz9000e7dwn101ajttd', 'cmqhs5qyl00007dwnv5y7uo6a', 5, 1, 'Kemunculan & Perkembangan Nasionalisme di Asia Tenggara', '["Imperialisme Barat","Gerakan nasionalis"]', '2026-06-17 07:59:33.333');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzc000g7dwnbd6fvmyi', 'cmqhs5qyl00007dwnv5y7uo6a', 5, 2, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Faktor kemunculan","Akhbar & majalah"]', '2026-06-17 07:59:33.336');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzf000i7dwn5dril983', 'cmqhs5qyl00007dwnv5y7uo6a', 5, 3, 'Kesedaran Pembinaan Negara dan Bangsa', '["Negara bangsa","Ciri-ciri negara bangsa"]', '2026-06-17 07:59:33.339');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzh000k7dwnu452gyua', 'cmqhs5qyl00007dwnv5y7uo6a', 5, 5, 'Pembinaan Negara dan Bangsa Yang Merdeka', '["Persekutuan Tanah Melayu 1948","Pakatan Murni","Kemerdekaan 1957"]', '2026-06-17 07:59:33.341');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzj000m7dwnxrb9eys7', 'cmqhs5qyl00007dwnv5y7uo6a', 5, 7, 'Sistem Pemerintahan dan Pentadbiran Negara', '["Raja Berperlembagaan","Demokrasi Berparlimen","Perlembagaan"]', '2026-06-17 07:59:33.344');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzo000p7dwnlgeuhifn', 'cmqhs5qzm000n7dwn9b1wr4vk', 4, 1, 'Karangan', '["Karangan berformat","Karangan tidak berformat"]', '2026-06-17 07:59:33.348');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzq000r7dwnhzq71ij5', 'cmqhs5qzm000n7dwn9b1wr4vk', 4, 2, 'Pemahaman & Rumusan', '["Rumusan","Soalan pemahaman"]', '2026-06-17 07:59:33.35');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzs000t7dwn712v9aoj', 'cmqhs5qzm000n7dwn9b1wr4vk', 5, 3, 'Tatabahasa', '["Kata","Frasa","Ayat"]', '2026-06-17 07:59:33.352');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzu000v7dwnw7lnfoo5', 'cmqhs5qzm000n7dwn9b1wr4vk', 5, 4, 'Komponen Sastera (KOMSAS)', '["Novel","Sajak","Cerpen","Drama"]', '2026-06-17 07:59:33.355');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5qzy000y7dwnwam1sgxo', 'cmqhs5qzw000w7dwnlom4v2kw', 4, 1, 'Reading Comprehension', '["Skimming","Scanning","Inference"]', '2026-06-17 07:59:33.358');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0000107dwn8s4omvrf', 'cmqhs5qzw000w7dwnlom4v2kw', 4, 2, 'Continuous Writing', '["Narrative","Descriptive","Argumentative"]', '2026-06-17 07:59:33.361');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0300127dwnmo3z7nfv', 'cmqhs5qzw000w7dwnlom4v2kw', 5, 3, 'Grammar in Use', '["Tenses","Subject-verb agreement"]', '2026-06-17 07:59:33.363');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0600147dwn0w4z9kfd', 'cmqhs5qzw000w7dwnlom4v2kw', 5, 4, 'Literature', '["Poem","Short story","Novel"]', '2026-06-17 07:59:33.367');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0a00177dwndqoev9dg', 'cmqhs5r0800157dwnfc5q7eux', 4, 1, 'Quadratic Functions & Equations', '["Roots","Discriminant","Graphs"]', '2026-06-17 07:59:33.371');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0c00197dwnqypnzaed', 'cmqhs5r0800157dwnfc5q7eux', 4, 3, 'Logarithms & Indices', '["Laws of indices","Laws of logarithms"]', '2026-06-17 07:59:33.373');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0f001b7dwn4ys650hx', 'cmqhs5r0800157dwnfc5q7eux', 5, 5, 'Probability', '["Combined events","Mutually exclusive"]', '2026-06-17 07:59:33.375');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0h001d7dwnvujgoa7p', 'cmqhs5r0800157dwnfc5q7eux', 5, 7, 'Statistics', '["Measures of dispersion","Standard deviation"]', '2026-06-17 07:59:33.377');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0l001g7dwn2lwrog1u', 'cmqhs5r0j001e7dwnxd0f36k7', 4, 1, 'Functions', '["Composite functions","Inverse functions"]', '2026-06-17 07:59:33.381');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0n001i7dwnbxuq6g8f', 'cmqhs5r0j001e7dwnxd0f36k7', 4, 5, 'Differentiation', '["First derivative","Rates of change"]', '2026-06-17 07:59:33.383');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0p001k7dwnaxjhgquj', 'cmqhs5r0j001e7dwnxd0f36k7', 5, 3, 'Integration', '["Indefinite","Definite","Area under curve"]', '2026-06-17 07:59:33.385');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0u001n7dwn2rsb51sm', 'cmqhs5r0r001l7dwn73whw3zw', 4, 2, 'Force and Motion', '["Newton''s laws","Momentum"]', '2026-06-17 07:59:33.39');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0w001p7dwnlkanpw9g', 'cmqhs5r0r001l7dwn73whw3zw', 4, 4, 'Heat', '["Specific heat capacity","Latent heat"]', '2026-06-17 07:59:33.392');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r0y001r7dwn66ac41ya', 'cmqhs5r0r001l7dwn73whw3zw', 5, 2, 'Electricity', '["Ohm''s law","Series & parallel"]', '2026-06-17 07:59:33.394');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r12001t7dwnwitxag5o', 'cmqhs5r0r001l7dwn73whw3zw', 5, 4, 'Electronics', '["Semiconductors","Logic gates"]', '2026-06-17 07:59:33.398');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r16001w7dwnzx8f7p97', 'cmqhs5r14001u7dwne6ghselr', 4, 3, 'Chemical Formulae & Equations', '["Mole concept","Empirical formula"]', '2026-06-17 07:59:33.403');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r18001y7dwnyshcdp1w', 'cmqhs5r14001u7dwne6ghselr', 4, 6, 'Acids, Bases and Salts', '["pH","Neutralisation","Preparation of salts"]', '2026-06-17 07:59:33.405');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r1b00207dwn8nka2iz3', 'cmqhs5r14001u7dwne6ghselr', 5, 2, 'Carbon Compounds', '["Hydrocarbons","Alcohols","Esters"]', '2026-06-17 07:59:33.407');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r1h00237dwn436nhksl', 'cmqhs5r1d00217dwnzbe3kfy8', 4, 2, 'Cell Structure & Organisation', '["Cell components","Diffusion & osmosis"]', '2026-06-17 07:59:33.413');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r1j00257dwnjq8qdjpg', 'cmqhs5r1d00217dwnzbe3kfy8', 4, 6, 'Nutrition', '["Photosynthesis","Human digestion"]', '2026-06-17 07:59:33.415');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhs5r1l00277dwn2inp5n2e', 'cmqhs5r1d00217dwnzbe3kfy8', 5, 3, 'Coordination and Response', '["Nervous system","Hormones"]', '2026-06-17 07:59:33.417');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r1r002b7dwnxdl1k7sb', 'cmqhs5qyl00007dwnv5y7uo6a', 'cmqhs5qyr00027dwn4koe72t4', 'cmqhs5r1n00297dwn0jkw659p', 1, 'mcq', '1', 'Tamadun awal manusia muncul di lembah sungai. Apakah faktor utama yang menggalakkan kemunculan tamadun di lembah sungai?', '[{"key":"A","text":"Tanah yang subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi yang selamat"},{"key":"C","text":"Kemudahan perlombongan bijih timah"},{"key":"D","text":"Hutan tebal untuk perburuan"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-17 07:59:33.423');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r1w002d7dwntw5xfj3p', 'cmqhs5qyl00007dwnv5y7uo6a', 'cmqhs5qz2000a7dwny9o725ct', 'cmqhs5r1n00297dwn0jkw659p', 1, 'mcq', '2', 'Piagam Madinah merupakan perlembagaan bertulis yang pertama di dunia. Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum dan agama"},{"key":"B","text":"Menyekat kegiatan perdagangan orang Yahudi"},{"key":"C","text":"Menghapuskan sistem perhambaan sepenuhnya"},{"key":"D","text":"Mewajibkan semua penduduk memeluk Islam"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-17 07:59:33.429');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r1y002f7dwnw9vmpsb8', 'cmqhs5qyl00007dwnv5y7uo6a', 'cmqhs5qzj000m7dwnxrb9eys7', 'cmqhs5r1n00297dwn0jkw659p', 1, 'mcq', '3', 'Sistem Raja Berperlembagaan diamalkan di Malaysia. Apakah maksud Raja Berperlembagaan?', '[{"key":"A","text":"Raja memerintah mengikut budi bicara mutlak"},{"key":"B","text":"Raja memerintah mengikut peruntukan Perlembagaan"},{"key":"C","text":"Raja tidak mempunyai sebarang kuasa"},{"key":"D","text":"Raja dilantik melalui pilihan raya"}]', 'B', NULL, NULL, 1, false, 'Raja Berperlembagaan', 2025, 'past_paper', '2026-06-17 07:59:33.431');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r21002h7dwnl209d1dq', 'cmqhs5qyl00007dwnv5y7uo6a', 'cmqhs5qyy00067dwnx1whl4x4', 'cmqhs5r1n00297dwn0jkw659p', 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Kegiatan ekonomi berasaskan perdagangan; terletak di kawasan pesisir pantai/muara sungai; mempunyai pelabuhan.', '1 markah bagi setiap ciri yang betul (maksimum 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-17 07:59:33.433');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r23002j7dwn2zbvvkxk', 'cmqhs5qyl00007dwnv5y7uo6a', 'cmqhs5qyy00067dwnx1whl4x4', 'cmqhs5r1n00297dwn0jkw659p', 2, 'structured', '1(b)', 'Pada pendapat anda, mengapakah kedudukan di muara sungai penting kepada kerajaan maritim?', '[]', 'Memudahkan urusan perdagangan; menjadi pusat pengumpulan barang dagangan; kawalan laluan perdagangan; pertahanan.', '2 markah bagi setiap jawapan munasabah dengan huraian (maksimum 4).', NULL, 4, true, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-17 07:59:33.436');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r25002l7dwns7zikuzk', 'cmqhs5qyl00007dwnv5y7uo6a', 'cmqhs5qzh000k7dwnu452gyua', 'cmqhs5r1n00297dwn0jkw659p', 2, 'essay', '5', 'Kemerdekaan Persekutuan Tanah Melayu pada tahun 1957 dicapai melalui semangat perpaduan dan rundingan. Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibar yang boleh diperoleh untuk mengekalkan kemerdekaan negara.', '[]', NULL, 'Isi: Pakatan Murni; Pilihan Raya 1955; Rombongan ke London 1956; Suruhanjaya Reid; pembentukan Perlembagaan. Nilai/iktibar: perpaduan, semangat patriotik, toleransi kaum, kepimpinan bijaksana.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks yang jelas"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}],"bands":[{"band":"Cemerlang","range":"16-20","descriptor":"Fakta tepat, huraian mendalam, nilai diterapkan"},{"band":"Baik","range":"11-15","descriptor":"Fakta mencukupi dengan sedikit huraian"},{"band":"Memuaskan","range":"6-10","descriptor":"Fakta asas sahaja"},{"band":"Lemah","range":"0-5","descriptor":"Fakta tidak relevan / terhad"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-17 07:59:33.438');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r28002n7dwn9nsmgyrc', 'cmqhs5r0800157dwnfc5q7eux', 'cmqhs5r0a00177dwndqoev9dg', NULL, 2, 'structured', NULL, 'The quadratic equation x² - 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'Equal roots ⇒ b² - 4ac = 0 ⇒ 36 - 4k = 0 ⇒ k = 9.', 'Use discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 07:59:33.44');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r2a002p7dwnr6ar99xd', 'cmqhs5r0r001l7dwn73whw3zw', 'cmqhs5r0u001n7dwn2rsb51sm', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 07:59:33.442');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r2d002r7dwn4r9mumsf', 'cmqhs5r14001u7dwne6ghselr', 'cmqhs5r18001y7dwnyshcdp1w', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water to produce ammonium ions and hydroxide ions (OH⁻), making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-17 07:59:33.446');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r2f002t7dwnqderfiib', 'cmqhs5r1d00217dwnzbe3kfy8', 'cmqhs5r1j00257dwnjq8qdjpg', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light reaction & Calvin cycle; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance (food, oxygen).', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-17 07:59:33.448');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r2h002v7dwn6uvt81fz', 'cmqhs5qzw000w7dwnlom4v2kw', 'cmqhs5r0000107dwn8s4omvrf', NULL, 2, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language (grammar, vocabulary), content relevance, and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-17 07:59:33.45');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt") VALUES ('cmqhs5r2k002x7dwncxd1o7b3', 'cmqhs5qzm000n7dwn9b1wr4vk', 'cmqhs5qzo000p7dwnlgeuhifn', NULL, 2, 'essay', NULL, 'Kebersihan alam sekitar menjadi tanggungjawab bersama. Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuatkuasa undang-undang, penanaman pokok. Huraian & contoh.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-17 07:59:33.452');


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhs5r2m002y7dwn3f3q5uhq', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-17 07:59:33.454');


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhs5r2r00307dwnwngsfygk', 'cmqhs5r2m002y7dwn3f3q5uhq', 'cmqhs5r1r002b7dwnxdl1k7sb', 'Jawapan contoh pelajar untuk tujuan demonstrasi.', 1, 1, NULL, true, '{"summary":"Seeded sample attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-17 07:59:33.459');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhs5r2v00327dwnhn5d5ei5', 'cmqhs5r2m002y7dwn3f3q5uhq', 'cmqhs5r1w002d7dwntw5xfj3p', 'B', 0, 1, NULL, false, '{"summary":"Seeded sample attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 150, '2026-06-17 07:59:33.463');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhs5r2y00347dwn128zd5ii', 'cmqhs5r2m002y7dwn3f3q5uhq', 'cmqhs5r1y002f7dwnw9vmpsb8', 'Jawapan contoh pelajar untuk tujuan demonstrasi.', 1, 1, NULL, true, '{"summary":"Seeded sample attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-17 07:59:33.466');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhs5r3100367dwnpvwckqg5', 'cmqhs5r2m002y7dwn3f3q5uhq', 'cmqhs5r21002h7dwnl209d1dq', 'Jawapan contoh pelajar untuk tujuan demonstrasi.', 2, 2, NULL, NULL, '{"summary":"Seeded sample attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 210, '2026-06-17 07:59:33.469');


--
-- Data for Name: GeneratedQuestion; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: MockPaper; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhs5r3300387dwn9xhd1ebb', 'cmqhs5r2m002y7dwn3f3q5uhq', 'cmqhs5qyl00007dwnv5y7uo6a', 1800, 4, '2026-06-17 07:59:33.472');


--
-- PostgreSQL database dump complete
--


