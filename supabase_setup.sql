-- ============================================================
-- SPM AI — one-shot Supabase setup (schema + seed)
-- Paste this whole file into Supabase -> SQL Editor -> Run.
-- RE-RUNNABLE: it resets the public schema first, so you can paste it
-- again any time the schema changes (this WIPES public-schema data).
-- Demo logins: admin@spm.my/admin123 · moderator@spm.my/mod123
--             ahmad@student.spm.my/student123
-- ============================================================

-- Reset (idempotent): drop & recreate the public schema
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
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
    "confidence" DOUBLE PRECISION,
    "autoApproved" BOOLEAN NOT NULL DEFAULT false,
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
CREATE TABLE public."KnowledgeDoc" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subjectId" TEXT,
    "form" INTEGER,
    "kind" TEXT NOT NULL DEFAULT 'note',
    "source" TEXT,
    "content" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "KnowledgeDoc_pkey" PRIMARY KEY ("id")
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
CREATE INDEX "KnowledgeDoc_subjectId_idx" ON public."KnowledgeDoc"("subjectId");

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
ALTER TABLE public."KnowledgeDoc" ADD CONSTRAINT "KnowledgeDoc_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"("id") ON DELETE SET NULL ON UPDATE CASCADE;

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

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5jd00007df6s81zojjb', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-17 10:54:49.802');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5k5000j7df625jv58r8', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-17 10:54:49.83');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5kk000s7df6v9vii3bu', 'English', 'English', 'ENG', '#2563eb', '2026-06-17 10:54:49.844');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5ku00117df6feipe3rh', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-17 10:54:49.854');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5l6001a7df63agy2o6c', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-17 10:54:49.866');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5lf001j7df65j658uxg', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-17 10:54:49.875');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5lo001s7df60bou4y2g', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-17 10:54:49.885');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhyf5lw001z7df62n0gyujb', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-17 10:54:49.892');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqhyf5n500317df62f5nzyk3', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqhyf5l6001a7df63agy2o6c', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 10:54:49.936', '2026-06-17 10:54:49.937');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqhyf5ne00397df6x31pjpkq', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqhyf5lw001z7df62n0gyujb', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 10:54:49.945', '2026-06-17 10:54:49.946');


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ji00027df6q3sv5cns', 'cmqhyf5jd00007df6s81zojjb', 4, 1, 'Kemunculan Tamadun Awal Manusia', '["Mesopotamia","Mesir Purba","Indus","Hwang Ho"]', '2026-06-17 10:54:49.807');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5jm00047df63d1l6akp', 'cmqhyf5jd00007df6s81zojjb', 4, 2, 'Peningkatan Tamadun', '["Yunani","Rom","India","China"]', '2026-06-17 10:54:49.811');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5jo00067df6h37acldu', 'cmqhyf5jd00007df6s81zojjb', 4, 3, 'Tamadun Awal di Asia Tenggara', '["Kerajaan agraria","Kerajaan maritim"]', '2026-06-17 10:54:49.813');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5jr00087df6q6dnxbw1', 'cmqhyf5jd00007df6s81zojjb', 4, 5, 'Kerajaan Islam di Madinah', '["Piagam Madinah","Perjanjian Hudaibiyah"]', '2026-06-17 10:54:49.815');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5jt000a7df6ci7ffeu5', 'cmqhyf5jd00007df6s81zojjb', 4, 9, 'Perkembangan di Eropah', '["Renaissance","Revolusi Perindustrian"]', '2026-06-17 10:54:49.817');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5jv000c7df6cqh01iyv', 'cmqhyf5jd00007df6s81zojjb', 5, 1, 'Kemunculan & Perkembangan Nasionalisme di Asia Tenggara', '["Imperialisme Barat","Gerakan nasionalis"]', '2026-06-17 10:54:49.82');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5jx000e7df668cfa9jv', 'cmqhyf5jd00007df6s81zojjb', 5, 2, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Faktor kemunculan","Akhbar & majalah"]', '2026-06-17 10:54:49.822');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5k1000g7df63b2ra8de', 'cmqhyf5jd00007df6s81zojjb', 5, 5, 'Pembinaan Negara dan Bangsa Yang Merdeka', '["Pakatan Murni","Kemerdekaan 1957"]', '2026-06-17 10:54:49.825');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5k3000i7df6z3n1w1hz', 'cmqhyf5jd00007df6s81zojjb', 5, 7, 'Sistem Pemerintahan dan Pentadbiran Negara', '["Raja Berperlembagaan","Demokrasi Berparlimen"]', '2026-06-17 10:54:49.828');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ka000l7df61q3q7lql', 'cmqhyf5k5000j7df625jv58r8', 4, 1, 'Karangan', '["Karangan berformat","Karangan tidak berformat"]', '2026-06-17 10:54:49.834');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5kc000n7df6kq0n5vbo', 'cmqhyf5k5000j7df625jv58r8', 4, 2, 'Pemahaman & Rumusan', '["Rumusan","Soalan pemahaman"]', '2026-06-17 10:54:49.836');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ke000p7df6krp7u6tn', 'cmqhyf5k5000j7df625jv58r8', 5, 3, 'Tatabahasa', '["Kata","Frasa","Ayat"]', '2026-06-17 10:54:49.838');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5kg000r7df617s67toh', 'cmqhyf5k5000j7df625jv58r8', 5, 4, 'Komponen Sastera (KOMSAS)', '["Novel","Sajak","Cerpen"]', '2026-06-17 10:54:49.84');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5kl000u7df6uqpitpcj', 'cmqhyf5kk000s7df6v9vii3bu', 4, 1, 'Reading Comprehension', '["Skimming","Scanning","Inference"]', '2026-06-17 10:54:49.846');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ko000w7df68eqn9wj5', 'cmqhyf5kk000s7df6v9vii3bu', 4, 2, 'Continuous Writing', '["Narrative","Descriptive","Argumentative"]', '2026-06-17 10:54:49.848');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5kq000y7df66e5a80lp', 'cmqhyf5kk000s7df6v9vii3bu', 5, 3, 'Grammar in Use', '["Tenses","Subject-verb agreement"]', '2026-06-17 10:54:49.85');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ks00107df6my5u0csh', 'cmqhyf5kk000s7df6v9vii3bu', 5, 4, 'Literature', '["Poem","Short story","Novel"]', '2026-06-17 10:54:49.852');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5kv00137df6xxh80p1z', 'cmqhyf5ku00117df6feipe3rh', 4, 1, 'Quadratic Functions & Equations', '["Roots","Discriminant","Graphs"]', '2026-06-17 10:54:49.856');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ky00157df6gcrcgrkp', 'cmqhyf5ku00117df6feipe3rh', 4, 3, 'Logarithms & Indices', '["Laws of indices","Laws of logarithms"]', '2026-06-17 10:54:49.859');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5l000177df686s0y79b', 'cmqhyf5ku00117df6feipe3rh', 5, 5, 'Probability', '["Combined events","Mutually exclusive"]', '2026-06-17 10:54:49.861');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5l200197df6wil0zlf4', 'cmqhyf5ku00117df6feipe3rh', 5, 7, 'Statistics', '["Dispersion","Standard deviation"]', '2026-06-17 10:54:49.862');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5l8001c7df6ktkd356f', 'cmqhyf5l6001a7df63agy2o6c', 4, 1, 'Functions', '["Composite functions","Inverse functions"]', '2026-06-17 10:54:49.868');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5la001e7df65m3n241s', 'cmqhyf5l6001a7df63agy2o6c', 4, 5, 'Differentiation', '["First derivative","Rates of change"]', '2026-06-17 10:54:49.87');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5lb001g7df6r83lfd48', 'cmqhyf5l6001a7df63agy2o6c', 5, 3, 'Integration', '["Indefinite","Definite","Area under curve"]', '2026-06-17 10:54:49.872');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ld001i7df6hrexnyie', 'cmqhyf5l6001a7df63agy2o6c', 5, 6, 'Permutations & Combinations', '["nPr","nCr"]', '2026-06-17 10:54:49.873');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5lh001l7df6528pbjgb', 'cmqhyf5lf001j7df65j658uxg', 4, 2, 'Force and Motion', '["Newton''s laws","Momentum"]', '2026-06-17 10:54:49.877');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5lj001n7df6ivgqmfc2', 'cmqhyf5lf001j7df65j658uxg', 4, 4, 'Heat', '["Specific heat capacity","Latent heat"]', '2026-06-17 10:54:49.879');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ll001p7df6ecqn0h7k', 'cmqhyf5lf001j7df65j658uxg', 5, 2, 'Electricity', '["Ohm''s law","Series & parallel"]', '2026-06-17 10:54:49.881');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ln001r7df633vpovny', 'cmqhyf5lf001j7df65j658uxg', 5, 4, 'Electronics', '["Semiconductors","Logic gates"]', '2026-06-17 10:54:49.883');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5lq001u7df63ssopzl6', 'cmqhyf5lo001s7df60bou4y2g', 4, 3, 'Chemical Formulae & Equations', '["Mole concept","Empirical formula"]', '2026-06-17 10:54:49.887');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5ls001w7df6t0ntlpne', 'cmqhyf5lo001s7df60bou4y2g', 4, 6, 'Acids, Bases and Salts', '["pH","Neutralisation","Salts"]', '2026-06-17 10:54:49.888');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5lu001y7df62cef2d22', 'cmqhyf5lo001s7df60bou4y2g', 5, 2, 'Carbon Compounds', '["Hydrocarbons","Alcohols","Esters"]', '2026-06-17 10:54:49.89');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5lz00217df60euuqapg', 'cmqhyf5lw001z7df62n0gyujb', 4, 2, 'Cell Structure & Organisation', '["Cell components","Diffusion & osmosis"]', '2026-06-17 10:54:49.895');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5m100237df6879gb82i', 'cmqhyf5lw001z7df62n0gyujb', 4, 6, 'Nutrition', '["Photosynthesis","Human digestion"]', '2026-06-17 10:54:49.897');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhyf5m300257df6b8umzik5', 'cmqhyf5lw001z7df62n0gyujb', 5, 3, 'Coordination and Response', '["Nervous system","Hormones"]', '2026-06-17 10:54:49.899');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5m500277df6nsjksmix', 'cmqhyf5jd00007df6s81zojjb', 'cmqhyf5ji00027df6q3sv5cns', NULL, 1, 'mcq', '1', 'Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?', '[{"key":"A","text":"Tanah subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi"},{"key":"C","text":"Perlombongan bijih timah"},{"key":"D","text":"Hutan tebal"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-17 10:54:49.902', 'Curated seed content', '2026-06-17 10:54:49.901', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5m900297df6ilx48rpf', 'cmqhyf5jd00007df6s81zojjb', 'cmqhyf5jr00087df6q6dnxbw1', NULL, 1, 'mcq', '2', 'Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum"},{"key":"B","text":"Menyekat perdagangan"},{"key":"C","text":"Menghapus perhambaan"},{"key":"D","text":"Mewajibkan satu agama"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-17 10:54:49.905', 'Curated seed content', '2026-06-17 10:54:49.904', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mb002b7df6pc6qh16l', 'cmqhyf5jd00007df6s81zojjb', 'cmqhyf5jo00067df6h37acldu', NULL, 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.', '1 markah setiap ciri (maks 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-17 10:54:49.907', 'Curated seed content', '2026-06-17 10:54:49.907', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5md002d7df6qohf38rc', 'cmqhyf5jd00007df6s81zojjb', 'cmqhyf5k1000g7df63b2ra8de', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-17 10:54:49.91', 'Curated seed content', '2026-06-17 10:54:49.909', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mf002f7df6dp73q3yi', 'cmqhyf5ku00117df6feipe3rh', 'cmqhyf5kv00137df6xxh80p1z', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.912', 'Curated seed content', '2026-06-17 10:54:49.911', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mh002h7df6mc7pbasy', 'cmqhyf5ku00117df6feipe3rh', 'cmqhyf5l000177df686s0y79b', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.914', 'Curated seed content', '2026-06-17 10:54:49.913', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5ml002j7df6ygmql5cv', 'cmqhyf5l6001a7df63agy2o6c', 'cmqhyf5la001e7df65m3n241s', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.917', 'Curated seed content', '2026-06-17 10:54:49.917', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mn002l7df6nr6e62bt', 'cmqhyf5lf001j7df65j658uxg', 'cmqhyf5lh001l7df6528pbjgb', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.92', 'Curated seed content', '2026-06-17 10:54:49.919', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mp002n7df6fkjc63zf', 'cmqhyf5lf001j7df65j658uxg', 'cmqhyf5lj001n7df6ivgqmfc2', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.922', 'Curated seed content', '2026-06-17 10:54:49.921', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mr002p7df6pqixxvjz', 'cmqhyf5lo001s7df60bou4y2g', 'cmqhyf5ls001w7df6t0ntlpne', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-17 10:54:49.924', 'Curated seed content', '2026-06-17 10:54:49.923', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mt002r7df66ie94p9l', 'cmqhyf5lo001s7df60bou4y2g', 'cmqhyf5ls001w7df6t0ntlpne', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', '2026-06-17 10:54:49.926', 'Curated seed content', '2026-06-17 10:54:49.925', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mw002t7df6bq7x3ywh', 'cmqhyf5lw001z7df62n0gyujb', 'cmqhyf5m100237df6879gb82i', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.928', 'Curated seed content', '2026-06-17 10:54:49.927', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mx002v7df65wnjtx41', 'cmqhyf5lw001z7df62n0gyujb', 'cmqhyf5lz00217df60euuqapg', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.93', 'Curated seed content', '2026-06-17 10:54:49.929', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5mz002x7df645aoe4ap', 'cmqhyf5kk000s7df6v9vii3bu', 'cmqhyf5ko000w7df68eqn9wj5', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.932', 'Curated seed content', '2026-06-17 10:54:49.931', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5n3002z7df6hy1parqw', 'cmqhyf5k5000j7df625jv58r8', 'cmqhyf5ka000l7df61q3q7lql', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-17 10:54:49.935', 'Curated seed content', '2026-06-17 10:54:49.934', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5n700337df6rl2jyg0s', 'cmqhyf5l6001a7df63agy2o6c', 'cmqhyf5l8001c7df6ktkd356f', 'cmqhyf5n500317df62f5nzyk3', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 10:54:49.94', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5n900357df67b6h8jcz', 'cmqhyf5l6001a7df63agy2o6c', 'cmqhyf5ld001i7df6hrexnyie', 'cmqhyf5n500317df62f5nzyk3', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 10:54:49.942', NULL, NULL, NULL, 'pending', false, 0.68);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5nc00377df6wc08nfwt', 'cmqhyf5l6001a7df63agy2o6c', 'cmqhyf5lb001g7df6r83lfd48', 'cmqhyf5n500317df62f5nzyk3', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', '2026-06-17 10:54:49.944', NULL, NULL, NULL, 'pending', false, 0.78);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5ng003b7df6i1dhwbz4', 'cmqhyf5lw001z7df62n0gyujb', 'cmqhyf5lz00217df60euuqapg', 'cmqhyf5ne00397df6x31pjpkq', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.948', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhyf5ni003d7df6krnxy2u4', 'cmqhyf5lw001z7df62n0gyujb', 'cmqhyf5m300257df6b8umzik5', 'cmqhyf5ne00397df6x31pjpkq', 2, 'structured', '2', 'Describe the path of a nerve impulse in a reflex arc.', '[]', 'Receptor → sensory neurone → relay neurone → motor neurone → effector.', 'Correct sequence (3m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 10:54:49.95', NULL, NULL, NULL, 'pending', false, 0.68);


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhyf5sb003m7df6kwpawu3j', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-17 10:54:50.123');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhyf5vs004j7df6oiju4i7z', 'Siti Nurhaliza', 'siti@student.spm.my', 5, '2026-06-17 10:54:50.248');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhyf5z8005g7df6f2q3e8xb', 'Kumar Raj', 'kumar@student.spm.my', 4, '2026-06-17 10:54:50.372');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhyf62l006f7df6102trwos', 'Mei Ling', 'meiling@student.spm.my', 5, '2026-06-17 10:54:50.494');


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5v900487df6q6nciu4d', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5m500277df6nsjksmix', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-09 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5ve004a7df6xylqhisu', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5mp002n7df6fkjc63zf', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-11 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5vh004c7df684w012er', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5m500277df6nsjksmix', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-12 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5vk004e7df61yux4wfq', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5mp002n7df6fkjc63zf', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-14 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5vn004g7df6xs4baj87', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5m500277df6nsjksmix', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-15 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5yj00517df6t1ajutfe', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5m900297df6ilx48rpf', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-06 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5yn00537df6chq23bup', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5mp002n7df6fkjc63zf', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-08 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5yq00557df6xn4b9nen', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5mf002f7df6dp73q3yi', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-09 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5yt00577df64z2hadyg', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5m500277df6nsjksmix', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-11 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5yw00597df6x4ymcf9n', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5mn002l7df6nr6e62bt', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-12 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5z1005b7df68y9rin7e', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5md002d7df6qohf38rc', 'Jawapan contoh pelajar.', 10, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-14 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf5z4005d7df6n8wytrmb', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5n3002z7df6hy1parqw', 'Jawapan contoh pelajar.', 21, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-15 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf61r005w7df68embkj56', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-03 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf61v005y7df6a0eft1qp', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-05 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf61y00607df6k9i9j4hy', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-06 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf62300627df6xw9uysxi', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-08 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf62600647df6ensxhx3v', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-09 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf62900667df6suxqif6v', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-11 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf62b00687df6apcbydy2', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-12 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf62e006a7df6aspp3b71', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-14 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf62h006c7df6nka1ttf8', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ml002j7df6ygmql5cv', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-15 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf658006v7df64rbc1nx3', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5md002d7df6qohf38rc', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-05-31 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65b006x7df65d1q1ss9', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5m500277df6nsjksmix', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-02 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65e006z7df6boqlw03q', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5mx002v7df65wnjtx41', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-03 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65h00717df642fq7a5i', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5mr002p7df6pqixxvjz', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-05 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65j00737df6io5t0t59', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5m900297df6ilx48rpf', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-06 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65m00757df6209hsrec', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5mz002x7df645aoe4ap', 'Jawapan contoh pelajar.', 23, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-08 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65p00777df6p2uhryev', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5mt002r7df66ie94p9l', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-09 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65s00797df6gazwvgha', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5mb002b7df6pc6qh16l', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-11 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65v007b7df6hvo3mkgg', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5n3002z7df6hy1parqw', 'Jawapan contoh pelajar.', 35, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-12 22:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf65y007d7df6hbyegx5g', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5mw002t7df6bq7x3ywh', 'Jawapan contoh pelajar.', 9, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-14 10:54:50.122');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhyf661007f7df6aznaglvf', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5md002d7df6qohf38rc', 'Jawapan contoh pelajar.', 16, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-15 22:54:50.122');


--
-- Data for Name: Enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5ug003q7df63m7ur5ic', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5jd00007df6s81zojjb', 'active', '2026-06-17 10:54:50.201');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5uk003s7df6q0di5c4m', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5ku00117df6feipe3rh', 'active', '2026-06-17 10:54:50.205');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5un003u7df6hgc1bfyz', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5lf001j7df65j658uxg', 'active', '2026-06-17 10:54:50.208');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5us003w7df6260kqns2', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5lo001s7df60bou4y2g', 'active', '2026-06-17 10:54:50.212');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5uv003y7df61doo0211', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5lw001z7df62n0gyujb', 'active', '2026-06-17 10:54:50.215');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5ux00407df6o2bmtp7v', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5k5000j7df625jv58r8', 'active', '2026-06-17 10:54:50.218');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5v000427df6g0x9hmzq', 'cmqhyf5sb003m7df6kwpawu3j', 'cmqhyf5kk000s7df6v9vii3bu', 'active', '2026-06-17 10:54:50.221');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5y1004n7df6ssucvfa8', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5jd00007df6s81zojjb', 'active', '2026-06-17 10:54:50.329');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5y4004p7df6o4rvf4zb', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5k5000j7df625jv58r8', 'active', '2026-06-17 10:54:50.332');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5y6004r7df6j5xfi29e', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5kk000s7df6v9vii3bu', 'active', '2026-06-17 10:54:50.334');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5y8004t7df6iy06e6bb', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5ku00117df6feipe3rh', 'active', '2026-06-17 10:54:50.337');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5yb004v7df6jzbqdugh', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5l6001a7df63agy2o6c', 'active', '2026-06-17 10:54:50.339');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf5yd004x7df6eofy2239', 'cmqhyf5vs004j7df6oiju4i7z', 'cmqhyf5lf001j7df65j658uxg', 'active', '2026-06-17 10:54:50.342');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf61c005k7df6djpt8zff', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5ku00117df6feipe3rh', 'active', '2026-06-17 10:54:50.449');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf61f005m7df6ku200as4', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5l6001a7df63agy2o6c', 'active', '2026-06-17 10:54:50.451');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf61h005o7df6535la8lk', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5lf001j7df65j658uxg', 'active', '2026-06-17 10:54:50.454');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf61k005q7df69eetln5u', 'cmqhyf5z8005g7df6f2q3e8xb', 'cmqhyf5lo001s7df60bou4y2g', 'active', '2026-06-17 10:54:50.456');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf64s006j7df6i0zjz9jo', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5jd00007df6s81zojjb', 'active', '2026-06-17 10:54:50.572');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf64u006l7df6p2v1ekbh', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5k5000j7df625jv58r8', 'active', '2026-06-17 10:54:50.575');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf64x006n7df6tjeuup29', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5kk000s7df6v9vii3bu', 'active', '2026-06-17 10:54:50.577');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf64z006p7df6u9dpo20w', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5lw001z7df62n0gyujb', 'active', '2026-06-17 10:54:50.58');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhyf653006r7df6lh3is192', 'cmqhyf62l006f7df6102trwos', 'cmqhyf5lo001s7df60bou4y2g', 'active', '2026-06-17 10:54:50.584');


--
-- Data for Name: KnowledgeDoc; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqhyf5nl003f7df6hal6oupv', 'Photosynthesis — key concepts', 'cmqhyf5lw001z7df62n0gyujb', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-17 10:54:49.953');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqhyf5no003h7df6q8gz95e3', 'Acids, bases & salts — essentials', 'cmqhyf5lo001s7df60bou4y2g', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-17 10:54:49.956');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqhyf5np003j7df64yosgpuv', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqhyf5jd00007df6s81zojjb', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-17 10:54:49.958');


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhyf5v300447df682ps3oet', 'cmqhyf5sb003m7df6kwpawu3j', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-12 10:54:50.122');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhyf5v500467df6lhakdn0e', 'cmqhyf5sb003m7df6kwpawu3j', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-07 10:54:50.122');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhyf5yg004z7df65jt2djw4', 'cmqhyf5vs004j7df6oiju4i7z', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-07 10:54:50.122');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhyf61m005s7df681nmy8nx', 'cmqhyf5z8005g7df6f2q3e8xb', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-02 10:54:50.122');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhyf61o005u7df6l0t7odp7', 'cmqhyf5z8005g7df6f2q3e8xb', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-05 10:54:50.122');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhyf656006t7df60avhn9yn', 'cmqhyf62l006f7df6102trwos', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-28 10:54:50.122');


--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhyf5vp004i7df6z7xl1tea', 'cmqhyf5sb003m7df6kwpawu3j', NULL, 1200, 5, '2026-06-17 10:54:50.246');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhyf5z6005f7df6erhy35is', 'cmqhyf5vs004j7df6oiju4i7z', NULL, 1800, 7, '2026-06-17 10:54:50.37');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhyf62j006e7df6jx1ewx32', 'cmqhyf5z8005g7df6f2q3e8xb', NULL, 2400, 9, '2026-06-17 10:54:50.492');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhyf664007h7df69gxrs800', 'cmqhyf62l006f7df6102trwos', NULL, 3000, 11, '2026-06-17 10:54:50.62');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhyf5q6003k7df65ncjp8ms', 'admin@spm.my', 'Admin Cikgu', 'admin', '12c80fd966a2e381505fbf34580e4a5c:a71c4790736b483a658f1570ce82ccc4789fe4c33eaf227d46e58a5d1c9cac4a967c59aa702f41be749cafb50f93a04bdc84076e0b0c4c3c76033e02219331e4', NULL, '2026-06-17 10:54:50.046');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhyf5s9003l7df6qfv7imbf', 'moderator@spm.my', 'Moderator Aisha', 'moderator', '37ef913d40bcb8374d32fe1aa5830c06:2e719040d8fb9da67522660cef0313e1ad766c78d66482a42b936344372f7338cb0c80a98b0db32e2a0ab7d821c334727da1547f1bdf633d791234c0f17a62b8', NULL, '2026-06-17 10:54:50.121');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhyf5ud003o7df6uezs3u4k', 'ahmad@student.spm.my', 'Ahmad', 'student', '437c199007a74038d23b6c82e054abcb:acb9d8af382f209899752927e6137a92e4be84281b4fa8df6ff80350043283b3e9a0344e3a56062dc4a0b5e3346311b3477b25d617017a8c2b85b4facd49d651', 'cmqhyf5sb003m7df6kwpawu3j', '2026-06-17 10:54:50.198');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhyf5xz004l7df6j0gr0ugh', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', 'f7c0e8a6859eb8fa787000492bd68bf6:79900aed444d3ec857a7c58006aa86a98229c99f90f861f7517039552f011bff982d024a0b907db5e06e4d14d62620d2e602ebb5714b0b922723454b23a7044a', 'cmqhyf5vs004j7df6oiju4i7z', '2026-06-17 10:54:50.327');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhyf61a005i7df617jpw0bu', 'kumar@student.spm.my', 'Kumar Raj', 'student', '13297ea4abee30318103ce2cb82b6d5b:c38b7d654a9201de2f80b92f59af005c4963e04c98f3b031a95bfc0e143c10aaa0c579d61e7f508f7f2b160bd191e6146ba96a326bc096e99eeda221b54c3c06', 'cmqhyf5z8005g7df6f2q3e8xb', '2026-06-17 10:54:50.446');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhyf64p006h7df6i8umlz9a', 'meiling@student.spm.my', 'Mei Ling', 'student', '21aeca0b863a745a6aa0d6b1e12b2687:1d1f478c1eab4673711c043266edb05df1150a8c825c6e75d059aed1f61349095be9e31ae1eebb9ae97cec8401769dd07905962b007756ac9334cffe13dd5786', 'cmqhyf62l006f7df6102trwos', '2026-06-17 10:54:50.57');


--
-- PostgreSQL database dump complete
--


