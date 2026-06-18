-- ============================================================
-- SPM AI — one-shot Supabase setup (schema + seed)
-- RE-RUNNABLE: resets the public schema first (WIPES public data).
-- Logins: admin@spm.my/Admin123@ · vikhash@student.spm.my/Vikhash123@
-- ============================================================

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
CREATE TABLE public."Bookmark" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Bookmark_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."ReviewItem" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "box" INTEGER NOT NULL DEFAULT 0,
    "dueAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastScorePct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "reps" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ReviewItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."Student" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "form" INTEGER NOT NULL DEFAULT 5,
    "whatsapp" TEXT,
    "pdpaConsent" BOOLEAN NOT NULL DEFAULT false,
    "consentAt" TIMESTAMP(3),
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
CREATE INDEX "Bookmark_studentId_idx" ON public."Bookmark"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "Bookmark_studentId_questionId_key" ON public."Bookmark"("studentId", "questionId");

-- CreateIndex
CREATE INDEX "ReviewItem_studentId_dueAt_idx" ON public."ReviewItem"("studentId", "dueAt");

-- CreateIndex
CREATE UNIQUE INDEX "ReviewItem_studentId_questionId_key" ON public."ReviewItem"("studentId", "questionId");

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
ALTER TABLE public."Bookmark" ADD CONSTRAINT "Bookmark_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."Bookmark" ADD CONSTRAINT "Bookmark_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."ReviewItem" ADD CONSTRAINT "ReviewItem_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE public."ReviewItem" ADD CONSTRAINT "ReviewItem_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"("id") ON DELETE CASCADE ON UPDATE CASCADE;

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

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0slsg00007dhh84vgpbn9', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-18 04:49:02.8');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0sltb000j7dhhge99vcz4', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-18 04:49:02.831');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0sltl000s7dhhujueyen9', 'English', 'English', 'ENG', '#2563eb', '2026-06-18 04:49:02.841');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0sltv00117dhhrv62i2dt', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-18 04:49:02.851');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0slu4001a7dhhxifahpgz', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-18 04:49:02.86');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0slud001j7dhht6fxfveu', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-18 04:49:02.869');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0slun001s7dhhp7320h9e', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-18 04:49:02.879');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj0sluu001z7dhhqrz27dkh', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-18 04:49:02.886');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj0slw300317dhh18be15af', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqj0slu4001a7dhhxifahpgz', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 04:49:02.93', '2026-06-18 04:49:02.931');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj0slwd00397dhhrb5w2tej', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqj0sluu001z7dhhqrz27dkh', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 04:49:02.941', '2026-06-18 04:49:02.942');


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slsn00027dhh9fv1dyo8', 'cmqj0slsg00007dhh84vgpbn9', 4, 1, 'Kemunculan Tamadun Awal Manusia', '["Mesopotamia","Mesir Purba","Indus","Hwang Ho"]', '2026-06-18 04:49:02.807');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slsr00047dhhx41592t2', 'cmqj0slsg00007dhh84vgpbn9', 4, 2, 'Peningkatan Tamadun', '["Yunani","Rom","India","China"]', '2026-06-18 04:49:02.811');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slsw00067dhhsy7kqbk5', 'cmqj0slsg00007dhh84vgpbn9', 4, 3, 'Tamadun Awal di Asia Tenggara', '["Kerajaan agraria","Kerajaan maritim"]', '2026-06-18 04:49:02.816');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slsy00087dhhkdv8hvt7', 'cmqj0slsg00007dhh84vgpbn9', 4, 5, 'Kerajaan Islam di Madinah', '["Piagam Madinah","Perjanjian Hudaibiyah"]', '2026-06-18 04:49:02.819');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slt1000a7dhh4fw5q85h', 'cmqj0slsg00007dhh84vgpbn9', 4, 9, 'Perkembangan di Eropah', '["Renaissance","Revolusi Perindustrian"]', '2026-06-18 04:49:02.821');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slt3000c7dhhosaw2n34', 'cmqj0slsg00007dhh84vgpbn9', 5, 1, 'Kemunculan & Perkembangan Nasionalisme di Asia Tenggara', '["Imperialisme Barat","Gerakan nasionalis"]', '2026-06-18 04:49:02.823');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slt5000e7dhhq401a2v2', 'cmqj0slsg00007dhh84vgpbn9', 5, 2, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Faktor kemunculan","Akhbar & majalah"]', '2026-06-18 04:49:02.825');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slt7000g7dhhscgdi30e', 'cmqj0slsg00007dhh84vgpbn9', 5, 5, 'Pembinaan Negara dan Bangsa Yang Merdeka', '["Pakatan Murni","Kemerdekaan 1957"]', '2026-06-18 04:49:02.827');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slt9000i7dhhd7mmui72', 'cmqj0slsg00007dhh84vgpbn9', 5, 7, 'Sistem Pemerintahan dan Pentadbiran Negara', '["Raja Berperlembagaan","Demokrasi Berparlimen"]', '2026-06-18 04:49:02.829');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltd000l7dhhwwwy3cqe', 'cmqj0sltb000j7dhhge99vcz4', 4, 1, 'Karangan', '["Karangan berformat","Karangan tidak berformat"]', '2026-06-18 04:49:02.833');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltf000n7dhhm9m5amwz', 'cmqj0sltb000j7dhhge99vcz4', 4, 2, 'Pemahaman & Rumusan', '["Rumusan","Soalan pemahaman"]', '2026-06-18 04:49:02.835');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slth000p7dhhho6bibk1', 'cmqj0sltb000j7dhhge99vcz4', 5, 3, 'Tatabahasa', '["Kata","Frasa","Ayat"]', '2026-06-18 04:49:02.838');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltj000r7dhhbi12xzm5', 'cmqj0sltb000j7dhhge99vcz4', 5, 4, 'Komponen Sastera (KOMSAS)', '["Novel","Sajak","Cerpen"]', '2026-06-18 04:49:02.84');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltn000u7dhhdk2lmvgf', 'cmqj0sltl000s7dhhujueyen9', 4, 1, 'Reading Comprehension', '["Skimming","Scanning","Inference"]', '2026-06-18 04:49:02.843');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltp000w7dhhtb0hyfg3', 'cmqj0sltl000s7dhhujueyen9', 4, 2, 'Continuous Writing', '["Narrative","Descriptive","Argumentative"]', '2026-06-18 04:49:02.846');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltr000y7dhhuclwebbw', 'cmqj0sltl000s7dhhujueyen9', 5, 3, 'Grammar in Use', '["Tenses","Subject-verb agreement"]', '2026-06-18 04:49:02.847');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltt00107dhh24pfz8io', 'cmqj0sltl000s7dhhujueyen9', 5, 4, 'Literature', '["Poem","Short story","Novel"]', '2026-06-18 04:49:02.849');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sltw00137dhhyncj2il2', 'cmqj0sltv00117dhhrv62i2dt', 4, 1, 'Quadratic Functions & Equations', '["Roots","Discriminant","Graphs"]', '2026-06-18 04:49:02.853');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slty00157dhhlvhwirhi', 'cmqj0sltv00117dhhrv62i2dt', 4, 3, 'Logarithms & Indices', '["Laws of indices","Laws of logarithms"]', '2026-06-18 04:49:02.854');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slu000177dhh7w1qaf6j', 'cmqj0sltv00117dhhrv62i2dt', 5, 5, 'Probability', '["Combined events","Mutually exclusive"]', '2026-06-18 04:49:02.856');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slu200197dhhkys42anr', 'cmqj0sltv00117dhhrv62i2dt', 5, 7, 'Statistics', '["Dispersion","Standard deviation"]', '2026-06-18 04:49:02.858');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slu6001c7dhhxzws4ytn', 'cmqj0slu4001a7dhhxifahpgz', 4, 1, 'Functions', '["Composite functions","Inverse functions"]', '2026-06-18 04:49:02.862');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slu8001e7dhht4p4gv3f', 'cmqj0slu4001a7dhhxifahpgz', 4, 5, 'Differentiation', '["First derivative","Rates of change"]', '2026-06-18 04:49:02.864');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slu9001g7dhhq88hhkua', 'cmqj0slu4001a7dhhxifahpgz', 5, 3, 'Integration', '["Indefinite","Definite","Area under curve"]', '2026-06-18 04:49:02.866');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slub001i7dhh5n2d7b37', 'cmqj0slu4001a7dhhxifahpgz', 5, 6, 'Permutations & Combinations', '["nPr","nCr"]', '2026-06-18 04:49:02.868');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sluf001l7dhhq9wr9rlc', 'cmqj0slud001j7dhht6fxfveu', 4, 2, 'Force and Motion', '["Newton''s laws","Momentum"]', '2026-06-18 04:49:02.871');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sluh001n7dhh55g6gy47', 'cmqj0slud001j7dhht6fxfveu', 4, 4, 'Heat', '["Specific heat capacity","Latent heat"]', '2026-06-18 04:49:02.874');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sluj001p7dhhfgb5kxgm', 'cmqj0slud001j7dhht6fxfveu', 5, 2, 'Electricity', '["Ohm''s law","Series & parallel"]', '2026-06-18 04:49:02.876');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slul001r7dhhunvjavcw', 'cmqj0slud001j7dhht6fxfveu', 5, 4, 'Electronics', '["Semiconductors","Logic gates"]', '2026-06-18 04:49:02.877');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sluo001u7dhhqhxogc1d', 'cmqj0slun001s7dhhp7320h9e', 4, 3, 'Chemical Formulae & Equations', '["Mole concept","Empirical formula"]', '2026-06-18 04:49:02.88');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sluq001w7dhhhhq7xqmg', 'cmqj0slun001s7dhhp7320h9e', 4, 6, 'Acids, Bases and Salts', '["pH","Neutralisation","Salts"]', '2026-06-18 04:49:02.883');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slus001y7dhhnlyii75t', 'cmqj0slun001s7dhhp7320h9e', 5, 2, 'Carbon Compounds', '["Hydrocarbons","Alcohols","Esters"]', '2026-06-18 04:49:02.885');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sluw00217dhhr90rvthc', 'cmqj0sluu001z7dhhqrz27dkh', 4, 2, 'Cell Structure & Organisation', '["Cell components","Diffusion & osmosis"]', '2026-06-18 04:49:02.888');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0slux00237dhh0c0jf81y', 'cmqj0sluu001z7dhhqrz27dkh', 4, 6, 'Nutrition', '["Photosynthesis","Human digestion"]', '2026-06-18 04:49:02.89');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj0sluz00257dhh3fogdwzh', 'cmqj0sluu001z7dhhqrz27dkh', 5, 3, 'Coordination and Response', '["Nervous system","Hormones"]', '2026-06-18 04:49:02.892');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slv200277dhhs049wp57', 'cmqj0slsg00007dhh84vgpbn9', 'cmqj0slsn00027dhh9fv1dyo8', NULL, 1, 'mcq', '1', 'Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?', '[{"key":"A","text":"Tanah subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi"},{"key":"C","text":"Perlombongan bijih timah"},{"key":"D","text":"Hutan tebal"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-18 04:49:02.894', 'Curated seed content', '2026-06-18 04:49:02.893', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slv700297dhherz4rtnb', 'cmqj0slsg00007dhh84vgpbn9', 'cmqj0slsy00087dhhkdv8hvt7', NULL, 1, 'mcq', '2', 'Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum"},{"key":"B","text":"Menyekat perdagangan"},{"key":"C","text":"Menghapus perhambaan"},{"key":"D","text":"Mewajibkan satu agama"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-18 04:49:02.9', 'Curated seed content', '2026-06-18 04:49:02.899', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slva002b7dhhchs5ncuz', 'cmqj0slsg00007dhh84vgpbn9', 'cmqj0slsw00067dhhsy7kqbk5', NULL, 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.', '1 markah setiap ciri (maks 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-18 04:49:02.902', 'Curated seed content', '2026-06-18 04:49:02.901', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvc002d7dhh0rnerd4b', 'cmqj0slsg00007dhh84vgpbn9', 'cmqj0slt7000g7dhhscgdi30e', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-18 04:49:02.904', 'Curated seed content', '2026-06-18 04:49:02.904', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slve002f7dhh8kjr1ezu', 'cmqj0sltv00117dhhrv62i2dt', 'cmqj0sltw00137dhhyncj2il2', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.907', 'Curated seed content', '2026-06-18 04:49:02.906', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvh002h7dhhayx3d5qq', 'cmqj0sltv00117dhhrv62i2dt', 'cmqj0slu000177dhh7w1qaf6j', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.909', 'Curated seed content', '2026-06-18 04:49:02.908', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvj002j7dhhx0oup3uu', 'cmqj0slu4001a7dhhxifahpgz', 'cmqj0slu8001e7dhht4p4gv3f', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.911', 'Curated seed content', '2026-06-18 04:49:02.91', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvl002l7dhheffg1ate', 'cmqj0slud001j7dhht6fxfveu', 'cmqj0sluf001l7dhhq9wr9rlc', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.913', 'Curated seed content', '2026-06-18 04:49:02.912', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvn002n7dhhfbpfh00c', 'cmqj0slud001j7dhht6fxfveu', 'cmqj0sluh001n7dhh55g6gy47', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.915', 'Curated seed content', '2026-06-18 04:49:02.914', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvq002p7dhhqitufhoc', 'cmqj0slun001s7dhhp7320h9e', 'cmqj0sluq001w7dhhhhq7xqmg', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-18 04:49:02.918', 'Curated seed content', '2026-06-18 04:49:02.918', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvs002r7dhhhj7wqdgn', 'cmqj0slun001s7dhhp7320h9e', 'cmqj0sluq001w7dhhhhq7xqmg', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', '2026-06-18 04:49:02.92', 'Curated seed content', '2026-06-18 04:49:02.92', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvu002t7dhhbp5kbes2', 'cmqj0sluu001z7dhhqrz27dkh', 'cmqj0slux00237dhh0c0jf81y', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.922', 'Curated seed content', '2026-06-18 04:49:02.921', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvw002v7dhhlnux256l', 'cmqj0sluu001z7dhhqrz27dkh', 'cmqj0sluw00217dhhr90rvthc', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.924', 'Curated seed content', '2026-06-18 04:49:02.924', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slvy002x7dhh4weq5nhz', 'cmqj0sltl000s7dhhujueyen9', 'cmqj0sltp000w7dhhtb0hyfg3', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.926', 'Curated seed content', '2026-06-18 04:49:02.926', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slw1002z7dhh7hweykih', 'cmqj0sltb000j7dhhge99vcz4', 'cmqj0sltd000l7dhhwwwy3cqe', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-18 04:49:02.929', 'Curated seed content', '2026-06-18 04:49:02.928', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slw600337dhhb6de7wv3', 'cmqj0slu4001a7dhhxifahpgz', 'cmqj0slu6001c7dhhxzws4ytn', 'cmqj0slw300317dhh18be15af', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-18 04:49:02.934', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slw900357dhhp3z2ab74', 'cmqj0slu4001a7dhhxifahpgz', 'cmqj0slub001i7dhh5n2d7b37', 'cmqj0slw300317dhh18be15af', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-18 04:49:02.937', NULL, NULL, NULL, 'pending', false, 0.68);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slwb00377dhhak0sn4ur', 'cmqj0slu4001a7dhhxifahpgz', 'cmqj0slu9001g7dhhq88hhkua', 'cmqj0slw300317dhh18be15af', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', '2026-06-18 04:49:02.94', NULL, NULL, NULL, 'pending', false, 0.78);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slwf003b7dhhmzu6ky5q', 'cmqj0sluu001z7dhhqrz27dkh', 'cmqj0sluw00217dhhr90rvthc', 'cmqj0slwd00397dhhrb5w2tej', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.944', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj0slwh003d7dhh9ny2dg10', 'cmqj0sluu001z7dhhqrz27dkh', 'cmqj0sluz00257dhh3fogdwzh', 'cmqj0slwd00397dhhrb5w2tej', 2, 'structured', '2', 'Describe the path of a nerve impulse in a reflex arc.', '[]', 'Receptor → sensory neurone → relay neurone → motor neurone → effector.', 'Correct sequence (3m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 04:49:02.946', NULL, NULL, NULL, 'pending', false, 0.68);


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp) VALUES ('cmqj0slzu003l7dhhu99idg91', 'Vikhash', 'vikhash@student.spm.my', 5, '2026-06-18 04:49:03.066', '2026-06-18 04:49:03.065', true, '+60123456789');
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp) VALUES ('cmqj0sm4g004k7dhhrx50tpyh', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-18 04:49:03.233', '2026-06-18 04:49:03.232', true, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp) VALUES ('cmqj0sm8h005j7dhhxg9rk64c', 'Siti Nurhaliza', 'siti@student.spm.my', 5, '2026-06-18 04:49:03.377', '2026-06-18 04:49:03.376', true, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp) VALUES ('cmqj0smcp006m7dhhxhxvycqo', 'Kumar Raj', 'kumar@student.spm.my', 4, '2026-06-18 04:49:03.529', '2026-06-18 04:49:03.528', true, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp) VALUES ('cmqj0smgt007n7dhh0je98qxd', 'Mei Ling', 'meiling@student.spm.my', 5, '2026-06-18 04:49:03.677', '2026-06-18 04:49:03.676', true, NULL);


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm3n00497dhhkpr7ov4f', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slv200277dhhs049wp57', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-10 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm3v004b7dhhgys1y1nm', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-12 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm44004d7dhh226mj7za', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slw1002z7dhh7hweykih', 'Jawapan contoh pelajar.', 22, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-13 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm48004f7dhhdtjwxm21', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slvj002j7dhhx0oup3uu', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-15 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm4b004h7dhhst3258i2', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slvy002x7dhh4weq5nhz', 'Jawapan contoh pelajar.', 13, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-16 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm7u00547dhhuwlg4b3x', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slv700297dhherz4rtnb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-07 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm7y00567dhhpr8lk775', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slvq002p7dhhqitufhoc', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-09 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm8100587dhh9pluetzi', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slv700297dhherz4rtnb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-10 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm84005a7dhhjr12d92t', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slvq002p7dhhqitufhoc', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-12 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm87005c7dhhvdjnezby', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slv700297dhherz4rtnb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-13 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm8a005e7dhh0qpycc48', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slvq002p7dhhqitufhoc', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-15 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sm8d005g7dhhpo0ddjya', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slv700297dhherz4rtnb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-16 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smbu00637dhh73gem293', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slva002b7dhhchs5ncuz', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-04 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smbx00657dhhxatv9vrb', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slvy002x7dhh4weq5nhz', 'Jawapan contoh pelajar.', 26, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-06 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smc000677dhh3duykj3l', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slvh002h7dhhayx3d5qq', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-07 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smc400697dhhhe18tw44', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slv700297dhherz4rtnb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-09 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smc7006b7dhh6fgfgbwu', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slvn002n7dhhfbpfh00c', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-10 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smca006d7dhh836wueo1', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slve002f7dhh8kjr1ezu', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-12 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smce006f7dhhyuogygi5', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slv200277dhhs049wp57', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-13 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smch006h7dhh4gzwos2e', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-15 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smcl006j7dhhqx20z3y4', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slvc002d7dhh0rnerd4b', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-16 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smfs00707dhhtbrevilx', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-01 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smfv00727dhh26clzrhk', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-03 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smg000747dhht6ikehmr', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-04 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smg300767dhha27ete1x', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-06 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smg600787dhhv1wzop4y', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-07 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smg9007a7dhh9b4owifo', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-09 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smgd007c7dhhcq07uzzu', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-10 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smgg007e7dhhaxa6uk6a', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-12 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smgj007g7dhhalhz4087', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-13 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smgm007i7dhhcgrcxbtg', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-15 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smgp007k7dhh9qykd9fs', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slvl002l7dhheffg1ate', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-16 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smk300857dhhol9oj6pr', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvq002p7dhhqitufhoc', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-05-29 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smk600877dhhmjrj7u2f', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slv700297dhherz4rtnb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-05-31 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smka00897dhh0hrd6dzg', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvy002x7dhh4weq5nhz', 'Jawapan contoh pelajar.', 19, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-01 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smkd008b7dhh0txn2uev', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvs002r7dhhhj7wqdgn', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-03 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smkg008d7dhh21i1pp1x', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slva002b7dhhchs5ncuz', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-04 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smkj008f7dhhjzecm1zi', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slw1002z7dhh7hweykih', 'Jawapan contoh pelajar.', 14, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-06 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smkm008h7dhhq62tfhb9', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvu002t7dhhbp5kbes2', 'Jawapan contoh pelajar.', 5, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-07 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smkr008j7dhh4s5mgk2t', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvc002d7dhh0rnerd4b', 'Jawapan contoh pelajar.', 12, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-09 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smku008l7dhh9m36xs10', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slv200277dhhs049wp57', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-10 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0smkx008n7dhhkv9o90ci', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvw002v7dhhlnux256l', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-12 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sml0008p7dhhs1o2ffbw', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvq002p7dhhqitufhoc', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-13 16:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sml3008r7dhhujf1nw9k', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slv700297dhherz4rtnb', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 280, '2026-06-15 04:49:03.065');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj0sml6008t7dhh2xcfyvmn', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slvy002x7dhh4weq5nhz', 'Jawapan contoh pelajar.', 14, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 300, '2026-06-16 16:49:03.065');


--
-- Data for Name: Enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm2l003p7dhh9ojp75q3', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slsg00007dhh84vgpbn9', 'active', '2026-06-18 04:49:03.166');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm2r003r7dhhvewri11g', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0sltb000j7dhhge99vcz4', 'active', '2026-06-18 04:49:03.171');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm2u003t7dhhrcj1yphy', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0sltl000s7dhhujueyen9', 'active', '2026-06-18 04:49:03.175');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm2y003v7dhhttx2n6ec', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0sltv00117dhhrv62i2dt', 'active', '2026-06-18 04:49:03.178');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm31003x7dhhcn7eq58e', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slu4001a7dhhxifahpgz', 'active', '2026-06-18 04:49:03.182');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm35003z7dhhfnuxlyhk', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slud001j7dhht6fxfveu', 'active', '2026-06-18 04:49:03.185');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm3800417dhhgwzmlmo7', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0slun001s7dhhp7320h9e', 'active', '2026-06-18 04:49:03.188');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm3b00437dhhdhpa448k', 'cmqj0slzu003l7dhhu99idg91', 'cmqj0sluu001z7dhhqrz27dkh', 'active', '2026-06-18 04:49:03.191');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm74004o7dhh80p8ib1l', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slsg00007dhh84vgpbn9', 'active', '2026-06-18 04:49:03.329');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm78004q7dhhe8wjy1p7', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0sltv00117dhhrv62i2dt', 'active', '2026-06-18 04:49:03.332');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm7b004s7dhhtq3mvgoy', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slud001j7dhht6fxfveu', 'active', '2026-06-18 04:49:03.335');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm7d004u7dhhi9gl2098', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0slun001s7dhhp7320h9e', 'active', '2026-06-18 04:49:03.338');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm7h004w7dhh0nvrxcxq', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0sluu001z7dhhqrz27dkh', 'active', '2026-06-18 04:49:03.341');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm7k004y7dhh0xomnk51', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0sltb000j7dhhge99vcz4', 'active', '2026-06-18 04:49:03.345');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0sm7o00507dhhgtque818', 'cmqj0sm4g004k7dhhrx50tpyh', 'cmqj0sltl000s7dhhujueyen9', 'active', '2026-06-18 04:49:03.348');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smb6005n7dhh25ewqt6l', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slsg00007dhh84vgpbn9', 'active', '2026-06-18 04:49:03.474');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smba005p7dhhawa0umor', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0sltb000j7dhhge99vcz4', 'active', '2026-06-18 04:49:03.478');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smbc005r7dhhwxs6732m', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0sltl000s7dhhujueyen9', 'active', '2026-06-18 04:49:03.481');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smbg005t7dhhzt6ftebj', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0sltv00117dhhrv62i2dt', 'active', '2026-06-18 04:49:03.484');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smbj005v7dhh62phgkv4', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slu4001a7dhhxifahpgz', 'active', '2026-06-18 04:49:03.487');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smbm005x7dhhvjnrolx8', 'cmqj0sm8h005j7dhhxg9rk64c', 'cmqj0slud001j7dhht6fxfveu', 'active', '2026-06-18 04:49:03.49');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smfc006q7dhh8cbfitvq', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0sltv00117dhhrv62i2dt', 'active', '2026-06-18 04:49:03.624');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smff006s7dhhwegt1apz', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slu4001a7dhhxifahpgz', 'active', '2026-06-18 04:49:03.628');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smfj006u7dhh5za2w2tc', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slud001j7dhht6fxfveu', 'active', '2026-06-18 04:49:03.631');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smfm006w7dhh0qsu6sw0', 'cmqj0smcp006m7dhhxhxvycqo', 'cmqj0slun001s7dhhp7320h9e', 'active', '2026-06-18 04:49:03.634');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smjg007r7dhhtxxrtvry', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slsg00007dhh84vgpbn9', 'active', '2026-06-18 04:49:03.772');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smjl007t7dhh53ee8065', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0sltb000j7dhhge99vcz4', 'active', '2026-06-18 04:49:03.777');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smjo007v7dhha0nkglyz', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0sltl000s7dhhujueyen9', 'active', '2026-06-18 04:49:03.78');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smjr007x7dhh68y30g6j', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0sluu001z7dhhqrz27dkh', 'active', '2026-06-18 04:49:03.784');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj0smju007z7dhh4791nj8b', 'cmqj0smgt007n7dhh0je98qxd', 'cmqj0slun001s7dhhp7320h9e', 'active', '2026-06-18 04:49:03.787');


--
-- Data for Name: KnowledgeDoc; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj0slwk003f7dhh74ctxw5a', 'Photosynthesis — key concepts', 'cmqj0sluu001z7dhhqrz27dkh', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-18 04:49:02.948');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj0slwm003h7dhhhap8dh4e', 'Acids, bases & salts — essentials', 'cmqj0slun001s7dhhp7320h9e', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-18 04:49:02.951');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj0slwo003j7dhh9zxfjycz', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqj0slsg00007dhh84vgpbn9', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-18 04:49:02.953');


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0sm3e00457dhhioid8yon', 'cmqj0slzu003l7dhhu99idg91', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-13 04:49:03.065');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0sm3h00477dhhkjip0fil', 'cmqj0slzu003l7dhhu99idg91', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-08 04:49:03.065');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0sm7r00527dhhwebt3vuw', 'cmqj0sm4g004k7dhhrx50tpyh', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-08 04:49:03.065');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0smbp005z7dhhsv8av3df', 'cmqj0sm8h005j7dhhxg9rk64c', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-03 04:49:03.065');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0smbr00617dhhlq1k5se5', 'cmqj0sm8h005j7dhhxg9rk64c', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-06 04:49:03.065');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0smfp006y7dhhik91rvtl', 'cmqj0smcp006m7dhhxhxvycqo', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-29 04:49:03.065');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0smjx00817dhhc14210mu', 'cmqj0smgt007n7dhh0je98qxd', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-05-24 04:49:03.065');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj0smjz00837dhh9l9swb89', 'cmqj0smgt007n7dhh0je98qxd', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-04 04:49:03.065');


--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj0sm4d004j7dhhdgoxx44n', 'cmqj0slzu003l7dhhu99idg91', NULL, 1200, 5, '2026-06-18 04:49:03.23');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj0sm8f005i7dhhcgfutav1', 'cmqj0sm4g004k7dhhrx50tpyh', NULL, 1800, 7, '2026-06-18 04:49:03.375');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj0smcn006l7dhhw0ga86k8', 'cmqj0sm8h005j7dhhxg9rk64c', NULL, 2400, 9, '2026-06-18 04:49:03.527');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj0smgr007m7dhhmqix2udp', 'cmqj0smcp006m7dhhxhxvycqo', NULL, 3000, 11, '2026-06-18 04:49:03.675');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj0sml8008v7dhhxj58516w', 'cmqj0smgt007n7dhh0je98qxd', NULL, 3600, 13, '2026-06-18 04:49:03.836');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj0slzo003k7dhhzni8a8li', 'admin@spm.my', 'Admin Cikgu', 'admin', 'd901e0078b44e0a3534f88cb4fc3620d:4953991bb0ab51fdf357855ac967db48f989eb9d0cafae3de6a96e592514d9760df107e472925a94e16bca5a6bb39a2fc23b7f634ad86ce86447fee8bd045cd4', NULL, '2026-06-18 04:49:03.06');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj0sm2h003n7dhhhrdywv3k', 'vikhash@student.spm.my', 'Vikhash', 'student', 'b7048163d35e7d5f3272d7f02b57581d:edb8dedd4bc55f64005fa32c24295bb927aa07dab65956e66218ee99683937204412eb2f44bbee30084a1b335f97c490091630cec6621f3845a6b343e1c8a91c', 'cmqj0slzu003l7dhhu99idg91', '2026-06-18 04:49:03.161');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj0sm71004m7dhhnyaeckyk', 'ahmad@student.spm.my', 'Ahmad', 'student', '41b0ac531e0061a6ecdc6e24aac2f91b:93d9c320595ba0c3d265619110c3c940c4f7b535c48ed497c854accb3c9802433e93530a1494087d6d8efb1d9692c1fa179be8a577e0169fec79ef87755b7411', 'cmqj0sm4g004k7dhhrx50tpyh', '2026-06-18 04:49:03.325');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj0smb1005l7dhh2qf4yhy8', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', '8179eab58789f2e7e1fdf7f5f9d912eb:46784f6a0f95dd567f6b960860f872d453a1a95627aece9e0b350f7643b2c1d4af3e4ac867f2961620e5bb67d23c7bebe64e8f39ceb551f2854167bf98a9d969', 'cmqj0sm8h005j7dhhxg9rk64c', '2026-06-18 04:49:03.47');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj0smf8006o7dhhl6l5n4vg', 'kumar@student.spm.my', 'Kumar Raj', 'student', '0837c32fd6fef425e5ff880dc4af1368:c24e041f31b1a2dc1321aff308c03fbd1a20c45f3dcb7b375aeb6ec28553fea2ea58b21d061e04b5e26caab4b4378e3ce5862b28ea0bf8d299872fc5fe121f8e', 'cmqj0smcp006m7dhhxhxvycqo', '2026-06-18 04:49:03.621');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj0smjc007p7dhhudbhk683', 'meiling@student.spm.my', 'Mei Ling', 'student', '69d843a4abef9440a43a932b773b055d:f8bb16958ae8b43edfaef1b058b418a507fc098c83ebe29ed722947210f41e2d2bde99d9d5110cc09c887242a66bf2e82fc5fcc6d19294f2b9bb0020d508e92a', 'cmqj0smgt007n7dhh0je98qxd', '2026-06-18 04:49:03.769');


--
-- PostgreSQL database dump complete
--


