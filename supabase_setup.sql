-- ============================================================
-- SPM AI — one-shot Supabase setup (schema + seed)
-- Paste this whole file into Supabase -> SQL Editor -> Run.
-- Fresh project: 12 tables + seed (roles, students, enrollments,
-- payments, approved + pending questions for moderation).
-- Demo logins: admin@spm.my/admin123 · moderator@spm.my/mod123
--             ahmad@student.spm.my/student123
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
    "status" TEXT NOT NULL DEFAULT 'approved',
    "reviewNote" TEXT,
    "reviewedById" TEXT,
    "reviewedAt" TIMESTAMP(3),
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
CREATE TABLE public."User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "studentId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Enrollment" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Enrollment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Payment" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'MYR',
    "method" TEXT,
    "status" TEXT NOT NULL DEFAULT 'paid',
    "description" TEXT,
    "paidAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
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
CREATE INDEX "Question_status_idx" ON public."Question"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Student_email_key" ON public."Student"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON public."User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_studentId_key" ON public."User"("studentId");

-- CreateIndex
CREATE INDEX "User_role_idx" ON public."User"("role");

-- CreateIndex
CREATE INDEX "Enrollment_studentId_idx" ON public."Enrollment"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "Enrollment_studentId_subjectId_key" ON public."Enrollment"("studentId", "subjectId");

-- CreateIndex
CREATE INDEX "Payment_studentId_idx" ON public."Payment"("studentId");

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
ALTER TABLE public."User" ADD CONSTRAINT "User_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Enrollment" ADD CONSTRAINT "Enrollment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Enrollment" ADD CONSTRAINT "Enrollment_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Payment" ADD CONSTRAINT "Payment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

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

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfwx00007dmq5zor8mq9', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-17 09:18:37.905');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfxn000j7dmqpojbbrdy', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-17 09:18:37.931');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfxw000s7dmqbfeakjmr', 'English', 'English', 'ENG', '#2563eb', '2026-06-17 09:18:37.941');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfy500117dmqcaokxb5u', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-17 09:18:37.949');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfye001a7dmqgxzsw7zj', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-17 09:18:37.958');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfyo001j7dmqox6nzzxp', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-17 09:18:37.968');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfyw001s7dmq9xju1re4', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-17 09:18:37.976');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhuzfz4001z7dmqhj527cor', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-17 09:18:37.984');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqhuzg0800317dmqcrq89sko', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqhuzfye001a7dmqgxzsw7zj', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 09:18:38.024', '2026-06-17 09:18:38.025');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqhuzg0i00397dmqppg5mc2p', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqhuzfz4001z7dmqhj527cor', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 09:18:38.033', '2026-06-17 09:18:38.034');


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfx300027dmq9jogubzj', 'cmqhuzfwx00007dmq5zor8mq9', 4, 1, 'Kemunculan Tamadun Awal Manusia', '["Mesopotamia","Mesir Purba","Indus","Hwang Ho"]', '2026-06-17 09:18:37.912');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfx700047dmq5kqf5bok', 'cmqhuzfwx00007dmq5zor8mq9', 4, 2, 'Peningkatan Tamadun', '["Yunani","Rom","India","China"]', '2026-06-17 09:18:37.916');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfx900067dmqo2aeamcz', 'cmqhuzfwx00007dmq5zor8mq9', 4, 3, 'Tamadun Awal di Asia Tenggara', '["Kerajaan agraria","Kerajaan maritim"]', '2026-06-17 09:18:37.918');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxb00087dmq8gbvaa7e', 'cmqhuzfwx00007dmq5zor8mq9', 4, 5, 'Kerajaan Islam di Madinah', '["Piagam Madinah","Perjanjian Hudaibiyah"]', '2026-06-17 09:18:37.92');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxd000a7dmqhal4ic7q', 'cmqhuzfwx00007dmq5zor8mq9', 4, 9, 'Perkembangan di Eropah', '["Renaissance","Revolusi Perindustrian"]', '2026-06-17 09:18:37.922');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxf000c7dmqrugibl0j', 'cmqhuzfwx00007dmq5zor8mq9', 5, 1, 'Kemunculan & Perkembangan Nasionalisme di Asia Tenggara', '["Imperialisme Barat","Gerakan nasionalis"]', '2026-06-17 09:18:37.923');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxh000e7dmqpj7o2lva', 'cmqhuzfwx00007dmq5zor8mq9', 5, 2, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Faktor kemunculan","Akhbar & majalah"]', '2026-06-17 09:18:37.925');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxj000g7dmqbck5w3gj', 'cmqhuzfwx00007dmq5zor8mq9', 5, 5, 'Pembinaan Negara dan Bangsa Yang Merdeka', '["Pakatan Murni","Kemerdekaan 1957"]', '2026-06-17 09:18:37.928');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxl000i7dmqckwja9f0', 'cmqhuzfwx00007dmq5zor8mq9', 5, 7, 'Sistem Pemerintahan dan Pentadbiran Negara', '["Raja Berperlembagaan","Demokrasi Berparlimen"]', '2026-06-17 09:18:37.929');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxo000l7dmqzsn434o8', 'cmqhuzfxn000j7dmqpojbbrdy', 4, 1, 'Karangan', '["Karangan berformat","Karangan tidak berformat"]', '2026-06-17 09:18:37.933');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxq000n7dmqet5nskdj', 'cmqhuzfxn000j7dmqpojbbrdy', 4, 2, 'Pemahaman & Rumusan', '["Rumusan","Soalan pemahaman"]', '2026-06-17 09:18:37.935');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxs000p7dmq5zk9km4e', 'cmqhuzfxn000j7dmqpojbbrdy', 5, 3, 'Tatabahasa', '["Kata","Frasa","Ayat"]', '2026-06-17 09:18:37.936');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxu000r7dmqawmtc7y2', 'cmqhuzfxn000j7dmqpojbbrdy', 5, 4, 'Komponen Sastera (KOMSAS)', '["Novel","Sajak","Cerpen"]', '2026-06-17 09:18:37.938');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfxy000u7dmqtgv23maa', 'cmqhuzfxw000s7dmqbfeakjmr', 4, 1, 'Reading Comprehension', '["Skimming","Scanning","Inference"]', '2026-06-17 09:18:37.942');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfy0000w7dmq228zn5o0', 'cmqhuzfxw000s7dmqbfeakjmr', 4, 2, 'Continuous Writing', '["Narrative","Descriptive","Argumentative"]', '2026-06-17 09:18:37.944');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfy1000y7dmqwcb1xdh0', 'cmqhuzfxw000s7dmqbfeakjmr', 5, 3, 'Grammar in Use', '["Tenses","Subject-verb agreement"]', '2026-06-17 09:18:37.946');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfy300107dmq6lwq8g5q', 'cmqhuzfxw000s7dmqbfeakjmr', 5, 4, 'Literature', '["Poem","Short story","Novel"]', '2026-06-17 09:18:37.947');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfy700137dmqdojk4bq2', 'cmqhuzfy500117dmqcaokxb5u', 4, 1, 'Quadratic Functions & Equations', '["Roots","Discriminant","Graphs"]', '2026-06-17 09:18:37.951');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfy800157dmqsptdqvie', 'cmqhuzfy500117dmqcaokxb5u', 4, 3, 'Logarithms & Indices', '["Laws of indices","Laws of logarithms"]', '2026-06-17 09:18:37.953');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfya00177dmqufpf0ohb', 'cmqhuzfy500117dmqcaokxb5u', 5, 5, 'Probability', '["Combined events","Mutually exclusive"]', '2026-06-17 09:18:37.955');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyc00197dmqi3uximfe', 'cmqhuzfy500117dmqcaokxb5u', 5, 7, 'Statistics', '["Dispersion","Standard deviation"]', '2026-06-17 09:18:37.956');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyf001c7dmqej3b4gj7', 'cmqhuzfye001a7dmqgxzsw7zj', 4, 1, 'Functions', '["Composite functions","Inverse functions"]', '2026-06-17 09:18:37.96');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyh001e7dmq2zrgtkgz', 'cmqhuzfye001a7dmqgxzsw7zj', 4, 5, 'Differentiation', '["First derivative","Rates of change"]', '2026-06-17 09:18:37.961');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyj001g7dmqvdtpk09h', 'cmqhuzfye001a7dmqgxzsw7zj', 5, 3, 'Integration', '["Indefinite","Definite","Area under curve"]', '2026-06-17 09:18:37.963');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfym001i7dmqdd12u2gp', 'cmqhuzfye001a7dmqgxzsw7zj', 5, 6, 'Permutations & Combinations', '["nPr","nCr"]', '2026-06-17 09:18:37.966');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyp001l7dmqmpoj39zd', 'cmqhuzfyo001j7dmqox6nzzxp', 4, 2, 'Force and Motion', '["Newton''s laws","Momentum"]', '2026-06-17 09:18:37.97');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyr001n7dmq5xwy09j2', 'cmqhuzfyo001j7dmqox6nzzxp', 4, 4, 'Heat', '["Specific heat capacity","Latent heat"]', '2026-06-17 09:18:37.971');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyt001p7dmqwqt7wd8f', 'cmqhuzfyo001j7dmqox6nzzxp', 5, 2, 'Electricity', '["Ohm''s law","Series & parallel"]', '2026-06-17 09:18:37.973');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyu001r7dmq1a3iibjb', 'cmqhuzfyo001j7dmqox6nzzxp', 5, 4, 'Electronics', '["Semiconductors","Logic gates"]', '2026-06-17 09:18:37.975');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfyy001u7dmqepnnt5ku', 'cmqhuzfyw001s7dmq9xju1re4', 4, 3, 'Chemical Formulae & Equations', '["Mole concept","Empirical formula"]', '2026-06-17 09:18:37.978');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfz0001w7dmqxzzcgx9s', 'cmqhuzfyw001s7dmq9xju1re4', 4, 6, 'Acids, Bases and Salts', '["pH","Neutralisation","Salts"]', '2026-06-17 09:18:37.98');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfz2001y7dmqh2ewfyjo', 'cmqhuzfyw001s7dmq9xju1re4', 5, 2, 'Carbon Compounds', '["Hydrocarbons","Alcohols","Esters"]', '2026-06-17 09:18:37.982');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfz500217dmq27afg7tu', 'cmqhuzfz4001z7dmqhj527cor', 4, 2, 'Cell Structure & Organisation', '["Cell components","Diffusion & osmosis"]', '2026-06-17 09:18:37.986');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfz700237dmq7wwtrnne', 'cmqhuzfz4001z7dmqhj527cor', 4, 6, 'Nutrition', '["Photosynthesis","Human digestion"]', '2026-06-17 09:18:37.988');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhuzfz900257dmqkqidr1e6', 'cmqhuzfz4001z7dmqhj527cor', 5, 3, 'Coordination and Response', '["Nervous system","Hormones"]', '2026-06-17 09:18:37.99');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzd00277dmqtg8qdxay', 'cmqhuzfwx00007dmq5zor8mq9', 'cmqhuzfx300027dmq9jogubzj', NULL, 1, 'mcq', '1', 'Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?', '[{"key":"A","text":"Tanah subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi"},{"key":"C","text":"Perlombongan bijih timah"},{"key":"D","text":"Hutan tebal"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-17 09:18:37.993', NULL, '2026-06-17 09:18:37.992', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzg00297dmqte4uide8', 'cmqhuzfwx00007dmq5zor8mq9', 'cmqhuzfxb00087dmq8gbvaa7e', NULL, 1, 'mcq', '2', 'Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum"},{"key":"B","text":"Menyekat perdagangan"},{"key":"C","text":"Menghapus perhambaan"},{"key":"D","text":"Mewajibkan satu agama"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-17 09:18:37.996', NULL, '2026-06-17 09:18:37.996', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzi002b7dmqt23r21yl', 'cmqhuzfwx00007dmq5zor8mq9', 'cmqhuzfx900067dmqo2aeamcz', NULL, 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.', '1 markah setiap ciri (maks 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-17 09:18:37.999', NULL, '2026-06-17 09:18:37.998', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzk002d7dmqpx44z87e', 'cmqhuzfwx00007dmq5zor8mq9', 'cmqhuzfxj000g7dmqbck5w3gj', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-17 09:18:38.001', NULL, '2026-06-17 09:18:38', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzm002f7dmqaxlu10zd', 'cmqhuzfy500117dmqcaokxb5u', 'cmqhuzfy700137dmqdojk4bq2', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.003', NULL, '2026-06-17 09:18:38.002', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzo002h7dmqggg5nwcm', 'cmqhuzfy500117dmqcaokxb5u', 'cmqhuzfya00177dmqufpf0ohb', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.005', NULL, '2026-06-17 09:18:38.004', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzr002j7dmq504n4046', 'cmqhuzfye001a7dmqgxzsw7zj', 'cmqhuzfyh001e7dmq2zrgtkgz', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.007', NULL, '2026-06-17 09:18:38.006', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzs002l7dmq75g84m0p', 'cmqhuzfyo001j7dmqox6nzzxp', 'cmqhuzfyp001l7dmqmpoj39zd', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.009', NULL, '2026-06-17 09:18:38.008', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzv002n7dmqq19nuoql', 'cmqhuzfyo001j7dmqox6nzzxp', 'cmqhuzfyr001n7dmq5xwy09j2', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.012', NULL, '2026-06-17 09:18:38.011', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzx002p7dmq3wrliglq', 'cmqhuzfyw001s7dmq9xju1re4', 'cmqhuzfz0001w7dmqxzzcgx9s', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-17 09:18:38.013', NULL, '2026-06-17 09:18:38.013', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzfzz002r7dmq5mkw35cz', 'cmqhuzfyw001s7dmq9xju1re4', 'cmqhuzfz0001w7dmqxzzcgx9s', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', '2026-06-17 09:18:38.015', NULL, '2026-06-17 09:18:38.015', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg01002t7dmq70xokewe', 'cmqhuzfz4001z7dmqhj527cor', 'cmqhuzfz700237dmq7wwtrnne', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.017', NULL, '2026-06-17 09:18:38.017', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg03002v7dmqmsllz5g7', 'cmqhuzfz4001z7dmqhj527cor', 'cmqhuzfz500217dmq27afg7tu', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.019', NULL, '2026-06-17 09:18:38.018', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg05002x7dmqmmd99cjm', 'cmqhuzfxw000s7dmqbfeakjmr', 'cmqhuzfy0000w7dmq228zn5o0', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.021', NULL, '2026-06-17 09:18:38.02', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg06002z7dmqmzim7xxe', 'cmqhuzfxn000j7dmqpojbbrdy', 'cmqhuzfxo000l7dmqzsn434o8', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-17 09:18:38.023', NULL, '2026-06-17 09:18:38.022', NULL, 'approved');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg0c00337dmq1etq99wd', 'cmqhuzfye001a7dmqgxzsw7zj', 'cmqhuzfyf001c7dmqej3b4gj7', 'cmqhuzg0800317dmqcrq89sko', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 09:18:38.028', NULL, NULL, NULL, 'pending');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg0e00357dmqhx9tw23c', 'cmqhuzfye001a7dmqgxzsw7zj', 'cmqhuzfym001i7dmqdd12u2gp', 'cmqhuzg0800317dmqcrq89sko', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 09:18:38.03', NULL, NULL, NULL, 'pending');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg0g00377dmqbdhltmjp', 'cmqhuzfye001a7dmqgxzsw7zj', 'cmqhuzfyj001g7dmqvdtpk09h', 'cmqhuzg0800317dmqcrq89sko', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', '2026-06-17 09:18:38.032', NULL, NULL, NULL, 'pending');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg0j003b7dmqors484u7', 'cmqhuzfz4001z7dmqhj527cor', 'cmqhuzfz500217dmq27afg7tu', 'cmqhuzg0i00397dmqppg5mc2p', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.036', NULL, NULL, NULL, 'pending');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status) VALUES ('cmqhuzg0l003d7dmqpg9xpobq', 'cmqhuzfz4001z7dmqhj527cor', 'cmqhuzfz900257dmqkqidr1e6', 'cmqhuzg0i00397dmqppg5mc2p', 2, 'structured', '2', 'Describe the path of a nerve impulse in a reflex arc.', '[]', 'Receptor → sensory neurone → relay neurone → motor neurone → effector.', 'Correct sequence (3m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 09:18:38.037', NULL, NULL, NULL, 'pending');


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhuzg5y003g7dmq2rcmzh1v', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-17 09:18:38.231');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhuzgaa004d7dmqzgdzgq83', 'Siti Nurhaliza', 'siti@student.spm.my', 5, '2026-06-17 09:18:38.386');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhuzge3005a7dmqtiydjv80', 'Kumar Raj', 'kumar@student.spm.my', 4, '2026-06-17 09:18:38.523');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhuzgi200697dmqq63igkw4', 'Mei Ling', 'meiling@student.spm.my', 5, '2026-06-17 09:18:38.666');


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzg9k00427dmqjd0rift8', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfzd00277dmqtg8qdxay', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-09 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzg9n00447dmqky2efpc1', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfzv002n7dmqq19nuoql', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-11 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzg9r00467dmqhcw98xxg', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfzd00277dmqtg8qdxay', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-12 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzg9w00487dmqhi5ux0rm', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfzv002n7dmqq19nuoql', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-14 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzga2004a7dmqtth21bnk', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfzd00277dmqtg8qdxay', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-15 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgde004v7dmqk192qice', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfzg00297dmqte4uide8', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-06 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgdi004x7dmqzzvriej5', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfzv002n7dmqq19nuoql', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-08 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgdn004z7dmq17s2vi19', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfzm002f7dmqaxlu10zd', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-09 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgdq00517dmqr0v0il9r', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfzd00277dmqtg8qdxay', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-11 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgdt00537dmq064nfl7r', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfzs002l7dmq75g84m0p', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-12 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgdw00557dmq1cqrk09f', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfzk002d7dmqpx44z87e', 'Jawapan contoh pelajar.', 10, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-14 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgdz00577dmq43j4r5x5', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzg06002z7dmqmzim7xxe', 'Jawapan contoh pelajar.', 21, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-15 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgha005q7dmqdjhkb1ge', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-03 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghd005s7dmqbce6klxo', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-05 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghg005u7dmqm96bhjq4', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-06 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghj005w7dmqt5lh85wc', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-08 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghm005y7dmqdzrgtlwe', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-09 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghp00607dmqxlxycvzt', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-11 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghs00627dmqxxoii3qv', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-12 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghv00647dmqlahfcsei', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-14 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzghy00667dmqpvn59oho', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfzr002j7dmq504n4046', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-15 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgl9006p7dmqq6xo64p3', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfzk002d7dmqpx44z87e', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-05-31 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzglc006r7dmqp74x9uy8', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfzd00277dmqtg8qdxay', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-02 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzglf006t7dmq0b3i4con', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzg03002v7dmqmsllz5g7', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-03 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgli006v7dmqxzeoutrg', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfzx002p7dmq3wrliglq', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-05 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgll006x7dmqlwwfs23d', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfzg00297dmqte4uide8', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-06 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzglo006z7dmqruop4xzt', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzg05002x7dmqmmd99cjm', 'Jawapan contoh pelajar.', 23, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-08 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzglr00717dmqnis8f0ws', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfzz002r7dmq5mkw35cz', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-09 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzglv00737dmqjhm7m7tf', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfzi002b7dmqt23r21yl', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-11 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgly00757dmqrjcbjvdt', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzg06002z7dmqmzim7xxe', 'Jawapan contoh pelajar.', 35, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-12 21:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgm100777dmqtl6gqmrf', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzg01002t7dmq70xokewe', 'Jawapan contoh pelajar.', 9, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-14 09:18:38.23');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhuzgm300797dmqgj8lte6n', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfzk002d7dmqpx44z87e', 'Jawapan contoh pelajar.', 16, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-15 21:18:38.23');


--
-- Data for Name: Enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzg8p003k7dmqngs09qc0', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfwx00007dmq5zor8mq9', 'active', '2026-06-17 09:18:38.329');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzg8u003m7dmqeslzq7xd', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfy500117dmqcaokxb5u', 'active', '2026-06-17 09:18:38.334');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzg8y003o7dmq5jh7puit', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfyo001j7dmqox6nzzxp', 'active', '2026-06-17 09:18:38.338');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzg91003q7dmq5c44dvr3', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfyw001s7dmq9xju1re4', 'active', '2026-06-17 09:18:38.341');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzg94003s7dmqywd0ey3q', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfz4001z7dmqhj527cor', 'active', '2026-06-17 09:18:38.344');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzg96003u7dmqr2h0hyvx', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfxn000j7dmqpojbbrdy', 'active', '2026-06-17 09:18:38.347');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzg99003w7dmqyxp4k3ah', 'cmqhuzg5y003g7dmq2rcmzh1v', 'cmqhuzfxw000s7dmqbfeakjmr', 'active', '2026-06-17 09:18:38.35');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgcu004h7dmqq0slr57g', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfwx00007dmq5zor8mq9', 'active', '2026-06-17 09:18:38.478');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgcx004j7dmqgyq1j1s1', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfxn000j7dmqpojbbrdy', 'active', '2026-06-17 09:18:38.482');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgd0004l7dmqrwclrkeq', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfxw000s7dmqbfeakjmr', 'active', '2026-06-17 09:18:38.485');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgd3004n7dmqmwhz6gey', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfy500117dmqcaokxb5u', 'active', '2026-06-17 09:18:38.487');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgd6004p7dmq5jaez9ne', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfye001a7dmqgxzsw7zj', 'active', '2026-06-17 09:18:38.49');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgd8004r7dmqx20ywy51', 'cmqhuzgaa004d7dmqzgdzgq83', 'cmqhuzfyo001j7dmqox6nzzxp', 'active', '2026-06-17 09:18:38.493');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzggp005e7dmqv73org2k', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfy500117dmqcaokxb5u', 'active', '2026-06-17 09:18:38.618');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzggt005g7dmquw4gatbj', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfye001a7dmqgxzsw7zj', 'active', '2026-06-17 09:18:38.621');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzggw005i7dmq8uo62vt7', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfyo001j7dmqox6nzzxp', 'active', '2026-06-17 09:18:38.625');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgh0005k7dmqa7o47hfk', 'cmqhuzge3005a7dmqtiydjv80', 'cmqhuzfyw001s7dmq9xju1re4', 'active', '2026-06-17 09:18:38.628');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgkr006d7dmqfsvxy42v', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfwx00007dmq5zor8mq9', 'active', '2026-06-17 09:18:38.763');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgku006f7dmqe0172x0c', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfxn000j7dmqpojbbrdy', 'active', '2026-06-17 09:18:38.767');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgkx006h7dmq6d1birdi', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfxw000s7dmqbfeakjmr', 'active', '2026-06-17 09:18:38.77');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgl0006j7dmq2mcz6hhh', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfz4001z7dmqhj527cor', 'active', '2026-06-17 09:18:38.773');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhuzgl3006l7dmq7qjc029o', 'cmqhuzgi200697dmqq63igkw4', 'cmqhuzfyw001s7dmq9xju1re4', 'active', '2026-06-17 09:18:38.775');


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhuzg9d003y7dmqdio0o05a', 'cmqhuzg5y003g7dmq2rcmzh1v', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-12 09:18:38.23');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhuzg9f00407dmqxutk9re6', 'cmqhuzg5y003g7dmq2rcmzh1v', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-07 09:18:38.23');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhuzgdb004t7dmqnpboh2xf', 'cmqhuzgaa004d7dmqzgdzgq83', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-07 09:18:38.23');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhuzgh3005m7dmqz0xboj09', 'cmqhuzge3005a7dmqtiydjv80', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-02 09:18:38.23');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhuzgh6005o7dmq7bos12cr', 'cmqhuzge3005a7dmqtiydjv80', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-05 09:18:38.23');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhuzgl5006n7dmqg2xe4xn8', 'cmqhuzgi200697dmqq63igkw4', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-28 09:18:38.23');


--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhuzga5004c7dmq5iwugsoe', 'cmqhuzg5y003g7dmq2rcmzh1v', NULL, 1200, 5, '2026-06-17 09:18:38.382');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhuzge100597dmqjoinuc25', 'cmqhuzgaa004d7dmqzgdzgq83', NULL, 1800, 7, '2026-06-17 09:18:38.521');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhuzgi000687dmqc2pskibf', 'cmqhuzge3005a7dmqtiydjv80', NULL, 2400, 9, '2026-06-17 09:18:38.665');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhuzgm5007b7dmqaqpqble3', 'cmqhuzgi200697dmqq63igkw4', NULL, 3000, 11, '2026-06-17 09:18:38.813');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhuzg3f003e7dmq5icq78ia', 'admin@spm.my', 'Admin Cikgu', 'admin', '55f749794b98b3725926d0762c18610c:67b234f0abef69522a2fff81379877b5cab4062d4e125799eed6e5b450551c3a35276ff242342bc8ed61a71e1e71c39839ca6d397003395993e55c87c0cd5a7f', NULL, '2026-06-17 09:18:38.139');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhuzg5v003f7dmq6yprab7e', 'moderator@spm.my', 'Moderator Aisha', 'moderator', '3ed21fbd64ebaaab0f56e0f51ddd7d83:6bb397d38985543aed91e46d9fa15134ea89bf3f63d9fd9c387b6c2c2eed6e75e0802b0718fb604d6a3fa50324f81ab1bfca22780fba37324e04c8e51a4ca1a2', NULL, '2026-06-17 09:18:38.227');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhuzg8j003i7dmq8d3i54zb', 'ahmad@student.spm.my', 'Ahmad', 'student', 'fed91b1878ad3feb08123ead524ec754:3a02967abc4ecfecdd561938be9a20ae2650dbebeb87554cb7e34efe601211cc32144edf5ccdd90c595408c87bed9b90998922bfc3005a4ee731db2ef7b1bf76', 'cmqhuzg5y003g7dmq2rcmzh1v', '2026-06-17 09:18:38.324');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhuzgcr004f7dmqpvseokjl', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', '3ac5131c5f1296b8adc22492fbf21705:1d0d394e70d61414fe7110aaa2d1f8e355b080aeb8d4c7161874f384c77ab11821a0cf2f559d6423e7f88c41cdd42158acb14c183c411383b35233739033d12c', 'cmqhuzgaa004d7dmqzgdzgq83', '2026-06-17 09:18:38.475');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhuzggm005c7dmqlr9qhbgo', 'kumar@student.spm.my', 'Kumar Raj', 'student', '1775c8a8de4a92e5650f14830789a293:07b5e897fe12ec5eb6b5eb07ce3aba89c576a55a8bdd9226e2eb99ca9aea508ab7d937305db4219105186e1cc76a3beb138e1b835000d7a6d4d56586113e6d83', 'cmqhuzge3005a7dmqtiydjv80', '2026-06-17 09:18:38.615');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhuzgkm006b7dmqo8lsz10h', 'meiling@student.spm.my', 'Mei Ling', 'student', '093009d89eb31799da276f3fe6716c09:0223b1a3a12fe1138474beb7911ccffb6471850db4fe0f67ff769ec97e3c9778ae0237ca377c6e9242c5643d6791554dcd0ae3cfeb23e26f086f76dc05012b30', 'cmqhuzgi200697dmqq63igkw4', '2026-06-17 09:18:38.758');


--
-- PostgreSQL database dump complete
--


