-- ============================================================
-- SPM AI — one-shot Supabase setup (schema + seed)
-- Paste this whole file into Supabase -> SQL Editor -> Run.
-- RE-RUNNABLE: it resets the public schema first, so you can paste it
-- again any time the schema changes (this WIPES public-schema data).
-- Demo logins: admin@spm.my/admin123 · ahmad@student.spm.my/student123
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

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjta500007dci6jyn35rp', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-17 11:26:26.813');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjtb0000j7dcir5pjpi2m', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-17 11:26:26.845');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjtb9000s7dciiwqrtmu1', 'English', 'English', 'ENG', '#2563eb', '2026-06-17 11:26:26.854');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjtbj00117dciz14lnw5f', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-17 11:26:26.863');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjtbs001a7dcind2avnxf', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-17 11:26:26.873');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjtc1001j7dcidenrc5ea', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-17 11:26:26.881');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjtcb001s7dciz8v5phdf', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-17 11:26:26.891');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqhzjtci001z7dcieceah92m', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-17 11:26:26.899');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqhzjtdr00317dcib86565da', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqhzjtbs001a7dcind2avnxf', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 11:26:26.943', '2026-06-17 11:26:26.944');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqhzjte200397dcigjyo492c', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqhzjtci001z7dcieceah92m', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 11:26:26.953', '2026-06-17 11:26:26.954');


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtac00027dciko1l1ase', 'cmqhzjta500007dci6jyn35rp', 4, 1, 'Kemunculan Tamadun Awal Manusia', '["Mesopotamia","Mesir Purba","Indus","Hwang Ho"]', '2026-06-17 11:26:26.821');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtah00047dciv240uf6o', 'cmqhzjta500007dci6jyn35rp', 4, 2, 'Peningkatan Tamadun', '["Yunani","Rom","India","China"]', '2026-06-17 11:26:26.825');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtal00067dcik27v8rxl', 'cmqhzjta500007dci6jyn35rp', 4, 3, 'Tamadun Awal di Asia Tenggara', '["Kerajaan agraria","Kerajaan maritim"]', '2026-06-17 11:26:26.83');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtao00087dcik2kxm1fb', 'cmqhzjta500007dci6jyn35rp', 4, 5, 'Kerajaan Islam di Madinah', '["Piagam Madinah","Perjanjian Hudaibiyah"]', '2026-06-17 11:26:26.832');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtaq000a7dci1eocu6t2', 'cmqhzjta500007dci6jyn35rp', 4, 9, 'Perkembangan di Eropah', '["Renaissance","Revolusi Perindustrian"]', '2026-06-17 11:26:26.834');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtas000c7dci42mpe11i', 'cmqhzjta500007dci6jyn35rp', 5, 1, 'Kemunculan & Perkembangan Nasionalisme di Asia Tenggara', '["Imperialisme Barat","Gerakan nasionalis"]', '2026-06-17 11:26:26.836');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtau000e7dcidgzc80m8', 'cmqhzjta500007dci6jyn35rp', 5, 2, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Faktor kemunculan","Akhbar & majalah"]', '2026-06-17 11:26:26.838');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtaw000g7dcia7v0dyst', 'cmqhzjta500007dci6jyn35rp', 5, 5, 'Pembinaan Negara dan Bangsa Yang Merdeka', '["Pakatan Murni","Kemerdekaan 1957"]', '2026-06-17 11:26:26.841');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtay000i7dci32k6zwpy', 'cmqhzjta500007dci6jyn35rp', 5, 7, 'Sistem Pemerintahan dan Pentadbiran Negara', '["Raja Berperlembagaan","Demokrasi Berparlimen"]', '2026-06-17 11:26:26.843');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtb2000l7dcim043kwoo', 'cmqhzjtb0000j7dcir5pjpi2m', 4, 1, 'Karangan', '["Karangan berformat","Karangan tidak berformat"]', '2026-06-17 11:26:26.846');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtb4000n7dcipu2hh8sh', 'cmqhzjtb0000j7dcir5pjpi2m', 4, 2, 'Pemahaman & Rumusan', '["Rumusan","Soalan pemahaman"]', '2026-06-17 11:26:26.848');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtb6000p7dcipg3zq6cd', 'cmqhzjtb0000j7dcir5pjpi2m', 5, 3, 'Tatabahasa', '["Kata","Frasa","Ayat"]', '2026-06-17 11:26:26.85');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtb7000r7dcipn2k8c30', 'cmqhzjtb0000j7dcir5pjpi2m', 5, 4, 'Komponen Sastera (KOMSAS)', '["Novel","Sajak","Cerpen"]', '2026-06-17 11:26:26.852');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbb000u7dciotevs6ni', 'cmqhzjtb9000s7dciiwqrtmu1', 4, 1, 'Reading Comprehension', '["Skimming","Scanning","Inference"]', '2026-06-17 11:26:26.855');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbe000w7dciktnjjt90', 'cmqhzjtb9000s7dciiwqrtmu1', 4, 2, 'Continuous Writing', '["Narrative","Descriptive","Argumentative"]', '2026-06-17 11:26:26.858');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbg000y7dci1zil6fsc', 'cmqhzjtb9000s7dciiwqrtmu1', 5, 3, 'Grammar in Use', '["Tenses","Subject-verb agreement"]', '2026-06-17 11:26:26.86');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbh00107dci8fpy3pr3', 'cmqhzjtb9000s7dciiwqrtmu1', 5, 4, 'Literature', '["Poem","Short story","Novel"]', '2026-06-17 11:26:26.862');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbl00137dcicerxbqvk', 'cmqhzjtbj00117dciz14lnw5f', 4, 1, 'Quadratic Functions & Equations', '["Roots","Discriminant","Graphs"]', '2026-06-17 11:26:26.865');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbn00157dciflslp8sk', 'cmqhzjtbj00117dciz14lnw5f', 4, 3, 'Logarithms & Indices', '["Laws of indices","Laws of logarithms"]', '2026-06-17 11:26:26.867');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbo00177dcilumic0q7', 'cmqhzjtbj00117dciz14lnw5f', 5, 5, 'Probability', '["Combined events","Mutually exclusive"]', '2026-06-17 11:26:26.869');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbq00197dci4nd2jp6b', 'cmqhzjtbj00117dciz14lnw5f', 5, 7, 'Statistics', '["Dispersion","Standard deviation"]', '2026-06-17 11:26:26.871');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbu001c7dcihck5ibzx', 'cmqhzjtbs001a7dcind2avnxf', 4, 1, 'Functions', '["Composite functions","Inverse functions"]', '2026-06-17 11:26:26.874');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbw001e7dcip6fvvxw8', 'cmqhzjtbs001a7dcind2avnxf', 4, 5, 'Differentiation', '["First derivative","Rates of change"]', '2026-06-17 11:26:26.876');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbx001g7dcidx0v9shj', 'cmqhzjtbs001a7dcind2avnxf', 5, 3, 'Integration', '["Indefinite","Definite","Area under curve"]', '2026-06-17 11:26:26.878');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtbz001i7dcipflevo78', 'cmqhzjtbs001a7dcind2avnxf', 5, 6, 'Permutations & Combinations', '["nPr","nCr"]', '2026-06-17 11:26:26.88');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtc4001l7dciqdr4xl3g', 'cmqhzjtc1001j7dcidenrc5ea', 4, 2, 'Force and Motion', '["Newton''s laws","Momentum"]', '2026-06-17 11:26:26.884');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtc5001n7dcizjtqs1u4', 'cmqhzjtc1001j7dcidenrc5ea', 4, 4, 'Heat', '["Specific heat capacity","Latent heat"]', '2026-06-17 11:26:26.886');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtc7001p7dci6wjswpq4', 'cmqhzjtc1001j7dcidenrc5ea', 5, 2, 'Electricity', '["Ohm''s law","Series & parallel"]', '2026-06-17 11:26:26.888');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtc9001r7dcihyw17qyr', 'cmqhzjtc1001j7dcidenrc5ea', 5, 4, 'Electronics', '["Semiconductors","Logic gates"]', '2026-06-17 11:26:26.889');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtcd001u7dci8ysr31gv', 'cmqhzjtcb001s7dciz8v5phdf', 4, 3, 'Chemical Formulae & Equations', '["Mole concept","Empirical formula"]', '2026-06-17 11:26:26.893');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtce001w7dcim3fupcxi', 'cmqhzjtcb001s7dciz8v5phdf', 4, 6, 'Acids, Bases and Salts', '["pH","Neutralisation","Salts"]', '2026-06-17 11:26:26.895');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtcg001y7dcigvjc0ret', 'cmqhzjtcb001s7dciz8v5phdf', 5, 2, 'Carbon Compounds', '["Hydrocarbons","Alcohols","Esters"]', '2026-06-17 11:26:26.897');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtck00217dcizdx6ckuh', 'cmqhzjtci001z7dcieceah92m', 4, 2, 'Cell Structure & Organisation', '["Cell components","Diffusion & osmosis"]', '2026-06-17 11:26:26.901');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtcm00237dcihio6g050', 'cmqhzjtci001z7dcieceah92m', 4, 6, 'Nutrition', '["Photosynthesis","Human digestion"]', '2026-06-17 11:26:26.902');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqhzjtco00257dci3n26c4v4', 'cmqhzjtci001z7dcieceah92m', 5, 3, 'Coordination and Response', '["Nervous system","Hormones"]', '2026-06-17 11:26:26.904');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtcr00277dciogk8s856', 'cmqhzjta500007dci6jyn35rp', 'cmqhzjtac00027dciko1l1ase', NULL, 1, 'mcq', '1', 'Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?', '[{"key":"A","text":"Tanah subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi"},{"key":"C","text":"Perlombongan bijih timah"},{"key":"D","text":"Hutan tebal"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-17 11:26:26.907', 'Curated seed content', '2026-06-17 11:26:26.906', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtcw00297dcipmqtqwro', 'cmqhzjta500007dci6jyn35rp', 'cmqhzjtao00087dcik2kxm1fb', NULL, 1, 'mcq', '2', 'Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum"},{"key":"B","text":"Menyekat perdagangan"},{"key":"C","text":"Menghapus perhambaan"},{"key":"D","text":"Mewajibkan satu agama"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-17 11:26:26.913', 'Curated seed content', '2026-06-17 11:26:26.912', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtcz002b7dci2z2036nb', 'cmqhzjta500007dci6jyn35rp', 'cmqhzjtal00067dcik27v8rxl', NULL, 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.', '1 markah setiap ciri (maks 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-17 11:26:26.915', 'Curated seed content', '2026-06-17 11:26:26.914', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtd1002d7dcinjzv1cyh', 'cmqhzjta500007dci6jyn35rp', 'cmqhzjtaw000g7dcia7v0dyst', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-17 11:26:26.918', 'Curated seed content', '2026-06-17 11:26:26.917', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtd4002f7dciqwtjt02p', 'cmqhzjtbj00117dciz14lnw5f', 'cmqhzjtbl00137dcicerxbqvk', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.92', 'Curated seed content', '2026-06-17 11:26:26.919', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtd6002h7dcif1z1l5od', 'cmqhzjtbj00117dciz14lnw5f', 'cmqhzjtbo00177dcilumic0q7', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.922', 'Curated seed content', '2026-06-17 11:26:26.921', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtd8002j7dciuldvkg9s', 'cmqhzjtbs001a7dcind2avnxf', 'cmqhzjtbw001e7dcip6fvvxw8', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.924', 'Curated seed content', '2026-06-17 11:26:26.923', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtda002l7dcike15bd4s', 'cmqhzjtc1001j7dcidenrc5ea', 'cmqhzjtc4001l7dciqdr4xl3g', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.926', 'Curated seed content', '2026-06-17 11:26:26.926', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdc002n7dci1btsabfm', 'cmqhzjtc1001j7dcidenrc5ea', 'cmqhzjtc5001n7dcizjtqs1u4', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.929', 'Curated seed content', '2026-06-17 11:26:26.928', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdf002p7dcim9rulqqu', 'cmqhzjtcb001s7dciz8v5phdf', 'cmqhzjtce001w7dcim3fupcxi', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-17 11:26:26.932', 'Curated seed content', '2026-06-17 11:26:26.931', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdh002r7dci8vjxgw4t', 'cmqhzjtcb001s7dciz8v5phdf', 'cmqhzjtce001w7dcim3fupcxi', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', '2026-06-17 11:26:26.934', 'Curated seed content', '2026-06-17 11:26:26.933', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdj002t7dcirv5xvs2x', 'cmqhzjtci001z7dcieceah92m', 'cmqhzjtcm00237dcihio6g050', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.936', 'Curated seed content', '2026-06-17 11:26:26.935', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdl002v7dci720zruos', 'cmqhzjtci001z7dcieceah92m', 'cmqhzjtck00217dcizdx6ckuh', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.938', 'Curated seed content', '2026-06-17 11:26:26.937', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdn002x7dcixxp6zpi3', 'cmqhzjtb9000s7dciiwqrtmu1', 'cmqhzjtbe000w7dciktnjjt90', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.94', 'Curated seed content', '2026-06-17 11:26:26.939', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdp002z7dciqysh59oh', 'cmqhzjtb0000j7dcir5pjpi2m', 'cmqhzjtb2000l7dcim043kwoo', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-17 11:26:26.942', 'Curated seed content', '2026-06-17 11:26:26.941', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdu00337dci7rztxrxk', 'cmqhzjtbs001a7dcind2avnxf', 'cmqhzjtbu001c7dcihck5ibzx', 'cmqhzjtdr00317dcib86565da', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 11:26:26.947', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjtdy00357dci4ugrbtrx', 'cmqhzjtbs001a7dcind2avnxf', 'cmqhzjtbz001i7dcipflevo78', 'cmqhzjtdr00317dcib86565da', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 11:26:26.95', NULL, NULL, NULL, 'pending', false, 0.68);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjte000377dcir2qake4h', 'cmqhzjtbs001a7dcind2avnxf', 'cmqhzjtbx001g7dcidx0v9shj', 'cmqhzjtdr00317dcib86565da', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', '2026-06-17 11:26:26.952', NULL, NULL, NULL, 'pending', false, 0.78);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjte4003b7dciwikfqcg8', 'cmqhzjtci001z7dcieceah92m', 'cmqhzjtck00217dcizdx6ckuh', 'cmqhzjte200397dcigjyo492c', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.956', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqhzjte6003d7dcixvemfenq', 'cmqhzjtci001z7dcieceah92m', 'cmqhzjtco00257dci3n26c4v4', 'cmqhzjte200397dcigjyo492c', 2, 'structured', '2', 'Describe the path of a nerve impulse in a reflex arc.', '[]', 'Receptor → sensory neurone → relay neurone → motor neurone → effector.', 'Correct sequence (3m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 11:26:26.958', NULL, NULL, NULL, 'pending', false, 0.68);


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhzjthn003l7dciwxads2f6', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-17 11:26:27.083');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhzjtli004i7dciv03rjpf1', 'Siti Nurhaliza', 'siti@student.spm.my', 5, '2026-06-17 11:26:27.223');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhzjtph005f7dci47d3nlcz', 'Kumar Raj', 'kumar@student.spm.my', 4, '2026-06-17 11:26:27.365');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqhzjttb006e7dci7kn2ra2g', 'Mei Ling', 'meiling@student.spm.my', 5, '2026-06-17 11:26:27.504');


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtl000477dci34i21uef', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtcr00277dciogk8s856', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-09 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtl500497dcipvqektq3', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtdc002n7dci1btsabfm', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-11 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtl9004b7dcixyzx3n85', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtcr00277dciogk8s856', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-12 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtlb004d7dcimowg4623', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtdc002n7dci1btsabfm', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-14 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtle004f7dciuaz20rz5', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtcr00277dciogk8s856', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-15 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtoo00507dcilaq342rq', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtcw00297dcipmqtqwro', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-06 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtos00527dcir21k7bj5', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtdc002n7dci1btsabfm', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-08 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtov00547dci8fmm3jzu', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtd4002f7dciqwtjt02p', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-09 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtoy00567dciwmbg0nm1', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtcr00277dciogk8s856', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-11 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtp100587dcidd4s9azo', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtda002l7dcike15bd4s', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-12 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtpa005a7dcicbctlzya', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtd1002d7dcinjzv1cyh', 'Jawapan contoh pelajar.', 10, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-14 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtpd005c7dci1uxzsgas', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtdp002z7dciqysh59oh', 'Jawapan contoh pelajar.', 21, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-15 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtsk005v7dcitza3m2ws', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-03 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtsn005x7dcib6jx1j08', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-05 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtsq005z7dcio02zna0e', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-06 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtss00617dci1f6xr5oq', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-08 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtsv00637dci95b5lx26', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-09 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtsy00657dci8yo81ii7', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-11 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtt100677dcirn9bwmzk', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-12 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtt400697dcilw1y0me7', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-14 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtt7006b7dciz2mdgb71', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtd8002j7dciuldvkg9s', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-15 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwc006u7dci2eb0m75t', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtd1002d7dcinjzv1cyh', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-05-31 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwf006w7dcix1k0uptk', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtcr00277dciogk8s856', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-02 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwi006y7dcie16rgbmi', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtdl002v7dci720zruos', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-03 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwm00707dcir7epx1p5', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtdf002p7dcim9rulqqu', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-05 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwp00727dciolqflq9x', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtcw00297dcipmqtqwro', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-06 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwt00747dcikywwpo5l', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtdn002x7dcixxp6zpi3', 'Jawapan contoh pelajar.', 23, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-08 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwv00767dci7etqnrsr', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtdh002r7dci8vjxgw4t', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-09 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtwz00787dcit9mwo5js', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtcz002b7dci2z2036nb', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-11 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtx2007a7dci77fs2gen', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtdp002z7dciqysh59oh', 'Jawapan contoh pelajar.', 35, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-12 23:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtx5007c7dcilfnkd3gn', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtdj002t7dcirv5xvs2x', 'Jawapan contoh pelajar.', 9, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-14 11:26:27.082');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqhzjtx8007e7dcideqsdpoi', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtd1002d7dcinjzv1cyh', 'Jawapan contoh pelajar.', 16, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-15 23:26:27.082');


--
-- Data for Name: Enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtk7003p7dcim3oku7lj', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjta500007dci6jyn35rp', 'active', '2026-06-17 11:26:27.175');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtkc003r7dci2erkszhy', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtbj00117dciz14lnw5f', 'active', '2026-06-17 11:26:27.18');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtkf003t7dci7jckdsfo', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtc1001j7dcidenrc5ea', 'active', '2026-06-17 11:26:27.183');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtki003v7dcinfrzguah', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtcb001s7dciz8v5phdf', 'active', '2026-06-17 11:26:27.186');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtkl003x7dcis137yqih', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtci001z7dcieceah92m', 'active', '2026-06-17 11:26:27.189');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtko003z7dci018u31mr', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtb0000j7dcir5pjpi2m', 'active', '2026-06-17 11:26:27.192');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtkr00417dci5y8vl5zv', 'cmqhzjthn003l7dciwxads2f6', 'cmqhzjtb9000s7dciiwqrtmu1', 'active', '2026-06-17 11:26:27.195');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjto3004m7dci3vwaheah', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjta500007dci6jyn35rp', 'active', '2026-06-17 11:26:27.315');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjto6004o7dci4ji71e6h', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtb0000j7dcir5pjpi2m', 'active', '2026-06-17 11:26:27.319');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjto9004q7dcis4lpkmcm', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtb9000s7dciiwqrtmu1', 'active', '2026-06-17 11:26:27.322');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtoc004s7dcih5gon6uf', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtbj00117dciz14lnw5f', 'active', '2026-06-17 11:26:27.324');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtof004u7dciencimvgu', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtbs001a7dcind2avnxf', 'active', '2026-06-17 11:26:27.327');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtoh004w7dci2sed9xmu', 'cmqhzjtli004i7dciv03rjpf1', 'cmqhzjtc1001j7dcidenrc5ea', 'active', '2026-06-17 11:26:27.33');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjts1005j7dcip4hpy20c', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtbj00117dciz14lnw5f', 'active', '2026-06-17 11:26:27.458');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjts5005l7dciblsx9owd', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtbs001a7dcind2avnxf', 'active', '2026-06-17 11:26:27.461');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjts9005n7dcibg3fi75d', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtc1001j7dcidenrc5ea', 'active', '2026-06-17 11:26:27.465');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtsc005p7dci5wr60hpx', 'cmqhzjtph005f7dci47d3nlcz', 'cmqhzjtcb001s7dciz8v5phdf', 'active', '2026-06-17 11:26:27.469');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtvu006i7dciuqgni3tf', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjta500007dci6jyn35rp', 'active', '2026-06-17 11:26:27.595');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtvy006k7dci37oyp5s8', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtb0000j7dcir5pjpi2m', 'active', '2026-06-17 11:26:27.598');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtw1006m7dcihox86sb9', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtb9000s7dciiwqrtmu1', 'active', '2026-06-17 11:26:27.601');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtw3006o7dcixqddeh10', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtci001z7dcieceah92m', 'active', '2026-06-17 11:26:27.604');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqhzjtw6006q7dcits74w5ng', 'cmqhzjttb006e7dci7kn2ra2g', 'cmqhzjtcb001s7dciz8v5phdf', 'active', '2026-06-17 11:26:27.607');


--
-- Data for Name: KnowledgeDoc; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqhzjte8003f7dcilwni90ot', 'Photosynthesis — key concepts', 'cmqhzjtci001z7dcieceah92m', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-17 11:26:26.96');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqhzjtea003h7dciw2pw5rbf', 'Acids, bases & salts — essentials', 'cmqhzjtcb001s7dciz8v5phdf', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-17 11:26:26.963');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqhzjtec003j7dci5mc41q07', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqhzjta500007dci6jyn35rp', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-17 11:26:26.964');


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhzjtku00437dcipz44iydx', 'cmqhzjthn003l7dciwxads2f6', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-12 11:26:27.082');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhzjtkw00457dci8uachj28', 'cmqhzjthn003l7dciwxads2f6', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-07 11:26:27.082');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhzjtol004y7dcizm4q31ok', 'cmqhzjtli004i7dciv03rjpf1', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-07 11:26:27.082');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhzjtsf005r7dcimmj51t9o', 'cmqhzjtph005f7dci47d3nlcz', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-02 11:26:27.082');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhzjtsh005t7dciup1j9bzg', 'cmqhzjtph005f7dci47d3nlcz', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-05 11:26:27.082');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqhzjtw9006s7dcilvzmg8np', 'cmqhzjttb006e7dci7kn2ra2g', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-28 11:26:27.082');


--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhzjtlg004h7dci7s92jap5', 'cmqhzjthn003l7dciwxads2f6', NULL, 1200, 5, '2026-06-17 11:26:27.221');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhzjtpf005e7dciyf8z5zai', 'cmqhzjtli004i7dciv03rjpf1', NULL, 1800, 7, '2026-06-17 11:26:27.363');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhzjtt9006d7dcivrj3lo96', 'cmqhzjtph005f7dci47d3nlcz', NULL, 2400, 9, '2026-06-17 11:26:27.502');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqhzjtxa007g7dcivchrxu16', 'cmqhzjttb006e7dci7kn2ra2g', NULL, 3000, 11, '2026-06-17 11:26:27.647');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhzjthh003k7dciabirjub1', 'admin@spm.my', 'Admin Cikgu', 'admin', '926a1140c1d0995b9b1b34cbe44085ff:d9d0fcee816fb4e539186bcb2363016c95285342918cce2a8c4638d396a124a7a54a4c2c909306b4a70ac4b8e60fa2e44bf3bed6bc668c293f58c6699a510be5', NULL, '2026-06-17 11:26:27.078');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhzjtk3003n7dcig8brorsw', 'ahmad@student.spm.my', 'Ahmad', 'student', 'd3742d37fbb11e2438464c9c63288c5f:39739c2d1ecae28081a1aa6657a9c74f44db8c2322b81b7a5609b1651f16836b251e1f57387ca6f5cc95c41c14a3840ef95105af893c9f6a6948013e3f51113c', 'cmqhzjthn003l7dciwxads2f6', '2026-06-17 11:26:27.171');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhzjto0004k7dci10qmm9gn', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', '479739057960532b74aedb576020328d:3bd59bfd4b41b276019aeab903996a79e15401042500c85bb4d91aa4ec823a4dcc36e496fde0c6960f6eaa4c0962ac62a7e2f0ec254cca0f5ff465fede0bd287', 'cmqhzjtli004i7dciv03rjpf1', '2026-06-17 11:26:27.312');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhzjtry005h7dciq17pkvxr', 'kumar@student.spm.my', 'Kumar Raj', 'student', '24976fb08e9cfd08e168223547479d82:4f9ce97bb167211c4c4526a449afccf2e145a691163d81ba3bcb19b6f65bf03ed5393ff193e7029402ea00d0ad8a541d8f951fbd6e79d5ca808b399914746661', 'cmqhzjtph005f7dci47d3nlcz', '2026-06-17 11:26:27.454');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqhzjtvr006g7dci7rau3q8d', 'meiling@student.spm.my', 'Mei Ling', 'student', '457bbc4cfa2d4a5d6c8cd95562b5434c:bd48f71df1f67771a71204df15c39fd364819d938aef18fddd79685d9d4fdde030ac3f09d95350a3e4d45d7db0596bfd9b68b1614a791d2d2ceb9d5cf46fc22d', 'cmqhzjttb006e7dci7kn2ra2g', '2026-06-17 11:26:27.592');


--
-- PostgreSQL database dump complete
--


