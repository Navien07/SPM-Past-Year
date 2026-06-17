-- ============================================================
-- SPM AI — one-shot Supabase setup (schema + seed)
-- RE-RUNNABLE: resets the public schema first (WIPES public data).
-- Demo logins: admin@spm.my/admin123 · ahmad@student.spm.my/student123
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

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqonk00007d4bypb4qla8', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-17 17:07:42.8');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqood000j7d4bv563ftzx', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-17 17:07:42.829');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqool000s7d4bg1dgcyyx', 'English', 'English', 'ENG', '#2563eb', '2026-06-17 17:07:42.837');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqoou00117d4buytmwdao', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-17 17:07:42.846');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqop3001a7d4bi4mhjlur', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-17 17:07:42.855');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqopb001j7d4bhwwigxdx', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-17 17:07:42.864');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqopj001s7d4brkvs9wky', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-17 17:07:42.872');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqibqopr001z7d4bzigqewwe', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-17 17:07:42.88');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqibqoqz00317d4blspzgid4', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqibqop3001a7d4bi4mhjlur', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 17:07:42.922', '2026-06-17 17:07:42.923');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqibqor700397d4bqxgc3v3v', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqibqopr001z7d4bzigqewwe', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-17 17:07:42.931', '2026-06-17 17:07:42.932');


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqonq00027d4bt6ga02vk', 'cmqibqonk00007d4bypb4qla8', 4, 1, 'Kemunculan Tamadun Awal Manusia', '["Mesopotamia","Mesir Purba","Indus","Hwang Ho"]', '2026-06-17 17:07:42.807');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqonu00047d4bivmd8c9z', 'cmqibqonk00007d4bypb4qla8', 4, 2, 'Peningkatan Tamadun', '["Yunani","Rom","India","China"]', '2026-06-17 17:07:42.811');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqonx00067d4bx5tf8wef', 'cmqibqonk00007d4bypb4qla8', 4, 3, 'Tamadun Awal di Asia Tenggara', '["Kerajaan agraria","Kerajaan maritim"]', '2026-06-17 17:07:42.813');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqonz00087d4b3fneapry', 'cmqibqonk00007d4bypb4qla8', 4, 5, 'Kerajaan Islam di Madinah', '["Piagam Madinah","Perjanjian Hudaibiyah"]', '2026-06-17 17:07:42.815');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoo1000a7d4bmwf4w10f', 'cmqibqonk00007d4bypb4qla8', 4, 9, 'Perkembangan di Eropah', '["Renaissance","Revolusi Perindustrian"]', '2026-06-17 17:07:42.817');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoo3000c7d4b6r3pmhxp', 'cmqibqonk00007d4bypb4qla8', 5, 1, 'Kemunculan & Perkembangan Nasionalisme di Asia Tenggara', '["Imperialisme Barat","Gerakan nasionalis"]', '2026-06-17 17:07:42.819');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoo5000e7d4by41lykpx', 'cmqibqonk00007d4bypb4qla8', 5, 2, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Faktor kemunculan","Akhbar & majalah"]', '2026-06-17 17:07:42.821');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoo9000g7d4b1ssh43oq', 'cmqibqonk00007d4bypb4qla8', 5, 5, 'Pembinaan Negara dan Bangsa Yang Merdeka', '["Pakatan Murni","Kemerdekaan 1957"]', '2026-06-17 17:07:42.825');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoob000i7d4bgo207jio', 'cmqibqonk00007d4bypb4qla8', 5, 7, 'Sistem Pemerintahan dan Pentadbiran Negara', '["Raja Berperlembagaan","Demokrasi Berparlimen"]', '2026-06-17 17:07:42.827');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqooe000l7d4bzv62qf71', 'cmqibqood000j7d4bv563ftzx', 4, 1, 'Karangan', '["Karangan berformat","Karangan tidak berformat"]', '2026-06-17 17:07:42.831');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoog000n7d4bysetdixx', 'cmqibqood000j7d4bv563ftzx', 4, 2, 'Pemahaman & Rumusan', '["Rumusan","Soalan pemahaman"]', '2026-06-17 17:07:42.832');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqooi000p7d4bvvt1uzin', 'cmqibqood000j7d4bv563ftzx', 5, 3, 'Tatabahasa', '["Kata","Frasa","Ayat"]', '2026-06-17 17:07:42.834');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqooj000r7d4bompakali', 'cmqibqood000j7d4bv563ftzx', 5, 4, 'Komponen Sastera (KOMSAS)', '["Novel","Sajak","Cerpen"]', '2026-06-17 17:07:42.836');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoon000u7d4ba15443mb', 'cmqibqool000s7d4bg1dgcyyx', 4, 1, 'Reading Comprehension', '["Skimming","Scanning","Inference"]', '2026-06-17 17:07:42.839');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoop000w7d4bslt0twqk', 'cmqibqool000s7d4bg1dgcyyx', 4, 2, 'Continuous Writing', '["Narrative","Descriptive","Argumentative"]', '2026-06-17 17:07:42.841');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqooq000y7d4b8u2aaral', 'cmqibqool000s7d4bg1dgcyyx', 5, 3, 'Grammar in Use', '["Tenses","Subject-verb agreement"]', '2026-06-17 17:07:42.843');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoos00107d4b5feg2gyn', 'cmqibqool000s7d4bg1dgcyyx', 5, 4, 'Literature', '["Poem","Short story","Novel"]', '2026-06-17 17:07:42.844');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoov00137d4bnxzs2tz7', 'cmqibqoou00117d4buytmwdao', 4, 1, 'Quadratic Functions & Equations', '["Roots","Discriminant","Graphs"]', '2026-06-17 17:07:42.848');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqoox00157d4baqgou0tp', 'cmqibqoou00117d4buytmwdao', 4, 3, 'Logarithms & Indices', '["Laws of indices","Laws of logarithms"]', '2026-06-17 17:07:42.849');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqooz00177d4bm1mtz9s2', 'cmqibqoou00117d4buytmwdao', 5, 5, 'Probability', '["Combined events","Mutually exclusive"]', '2026-06-17 17:07:42.852');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqop100197d4bbkslk7bs', 'cmqibqoou00117d4buytmwdao', 5, 7, 'Statistics', '["Dispersion","Standard deviation"]', '2026-06-17 17:07:42.853');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqop4001c7d4bx1u2j48h', 'cmqibqop3001a7d4bi4mhjlur', 4, 1, 'Functions', '["Composite functions","Inverse functions"]', '2026-06-17 17:07:42.857');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqop6001e7d4b98bbjcmg', 'cmqibqop3001a7d4bi4mhjlur', 4, 5, 'Differentiation', '["First derivative","Rates of change"]', '2026-06-17 17:07:42.858');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqop8001g7d4bagsjby24', 'cmqibqop3001a7d4bi4mhjlur', 5, 3, 'Integration', '["Indefinite","Definite","Area under curve"]', '2026-06-17 17:07:42.86');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopa001i7d4bw8d5ptdb', 'cmqibqop3001a7d4bi4mhjlur', 5, 6, 'Permutations & Combinations', '["nPr","nCr"]', '2026-06-17 17:07:42.862');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopd001l7d4bu10rcmy6', 'cmqibqopb001j7d4bhwwigxdx', 4, 2, 'Force and Motion', '["Newton''s laws","Momentum"]', '2026-06-17 17:07:42.865');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopf001n7d4blwpxfzpo', 'cmqibqopb001j7d4bhwwigxdx', 4, 4, 'Heat', '["Specific heat capacity","Latent heat"]', '2026-06-17 17:07:42.867');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopg001p7d4bl67jg4j3', 'cmqibqopb001j7d4bhwwigxdx', 5, 2, 'Electricity', '["Ohm''s law","Series & parallel"]', '2026-06-17 17:07:42.869');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopi001r7d4bb1qq4mju', 'cmqibqopb001j7d4bhwwigxdx', 5, 4, 'Electronics', '["Semiconductors","Logic gates"]', '2026-06-17 17:07:42.87');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopl001u7d4bkzo24nvk', 'cmqibqopj001s7d4brkvs9wky', 4, 3, 'Chemical Formulae & Equations', '["Mole concept","Empirical formula"]', '2026-06-17 17:07:42.873');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopo001w7d4bpjqcsdk3', 'cmqibqopj001s7d4brkvs9wky', 4, 6, 'Acids, Bases and Salts', '["pH","Neutralisation","Salts"]', '2026-06-17 17:07:42.876');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopq001y7d4b52juvbvm', 'cmqibqopj001s7d4brkvs9wky', 5, 2, 'Carbon Compounds', '["Hydrocarbons","Alcohols","Esters"]', '2026-06-17 17:07:42.878');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopt00217d4b6hxmdk7u', 'cmqibqopr001z7d4bzigqewwe', 4, 2, 'Cell Structure & Organisation', '["Cell components","Diffusion & osmosis"]', '2026-06-17 17:07:42.881');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopu00237d4bxswft6nu', 'cmqibqopr001z7d4bzigqewwe', 4, 6, 'Nutrition', '["Photosynthesis","Human digestion"]', '2026-06-17 17:07:42.883');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqibqopw00257d4by5d9qu77', 'cmqibqopr001z7d4bzigqewwe', 5, 3, 'Coordination and Response', '["Nervous system","Hormones"]', '2026-06-17 17:07:42.885');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqopz00277d4bgrjr73gw', 'cmqibqonk00007d4bypb4qla8', 'cmqibqonq00027d4bt6ga02vk', NULL, 1, 'mcq', '1', 'Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?', '[{"key":"A","text":"Tanah subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi"},{"key":"C","text":"Perlombongan bijih timah"},{"key":"D","text":"Hutan tebal"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-17 17:07:42.887', 'Curated seed content', '2026-06-17 17:07:42.886', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoq200297d4bfw6z1iqb', 'cmqibqonk00007d4bypb4qla8', 'cmqibqonz00087d4b3fneapry', NULL, 1, 'mcq', '2', 'Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum"},{"key":"B","text":"Menyekat perdagangan"},{"key":"C","text":"Menghapus perhambaan"},{"key":"D","text":"Mewajibkan satu agama"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-17 17:07:42.891', 'Curated seed content', '2026-06-17 17:07:42.89', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoq5002b7d4bdq68okx4', 'cmqibqonk00007d4bypb4qla8', 'cmqibqonx00067d4bx5tf8wef', NULL, 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.', '1 markah setiap ciri (maks 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-17 17:07:42.893', 'Curated seed content', '2026-06-17 17:07:42.892', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoq7002d7d4b8kasevn5', 'cmqibqonk00007d4bypb4qla8', 'cmqibqoo9000g7d4b1ssh43oq', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-17 17:07:42.895', 'Curated seed content', '2026-06-17 17:07:42.895', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqa002f7d4byton4n24', 'cmqibqoou00117d4buytmwdao', 'cmqibqoov00137d4bnxzs2tz7', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.899', 'Curated seed content', '2026-06-17 17:07:42.898', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqd002h7d4bm1ukvdw8', 'cmqibqoou00117d4buytmwdao', 'cmqibqooz00177d4bm1mtz9s2', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.901', 'Curated seed content', '2026-06-17 17:07:42.9', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqf002j7d4bxmtpdkna', 'cmqibqop3001a7d4bi4mhjlur', 'cmqibqop6001e7d4b98bbjcmg', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.903', 'Curated seed content', '2026-06-17 17:07:42.902', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqh002l7d4bgim7j4lj', 'cmqibqopb001j7d4bhwwigxdx', 'cmqibqopd001l7d4bu10rcmy6', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.905', 'Curated seed content', '2026-06-17 17:07:42.904', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqj002n7d4bvegrhoki', 'cmqibqopb001j7d4bhwwigxdx', 'cmqibqopf001n7d4blwpxfzpo', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.907', 'Curated seed content', '2026-06-17 17:07:42.906', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoql002p7d4bfcvkuxrd', 'cmqibqopj001s7d4brkvs9wky', 'cmqibqopo001w7d4bpjqcsdk3', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-17 17:07:42.909', 'Curated seed content', '2026-06-17 17:07:42.908', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqn002r7d4byoqnggbv', 'cmqibqopj001s7d4brkvs9wky', 'cmqibqopo001w7d4bpjqcsdk3', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', '2026-06-17 17:07:42.911', 'Curated seed content', '2026-06-17 17:07:42.911', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqp002t7d4bjw4uocj6', 'cmqibqopr001z7d4bzigqewwe', 'cmqibqopu00237d4bxswft6nu', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.914', 'Curated seed content', '2026-06-17 17:07:42.913', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqs002v7d4bs0od2k2s', 'cmqibqopr001z7d4bzigqewwe', 'cmqibqopt00217d4b6hxmdk7u', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.917', 'Curated seed content', '2026-06-17 17:07:42.916', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqv002x7d4bvs3jx153', 'cmqibqool000s7d4bg1dgcyyx', 'cmqibqoop000w7d4bslt0twqk', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.919', 'Curated seed content', '2026-06-17 17:07:42.918', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqoqx002z7d4bijtds98w', 'cmqibqood000j7d4bv563ftzx', 'cmqibqooe000l7d4bzv62qf71', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-17 17:07:42.921', 'Curated seed content', '2026-06-17 17:07:42.92', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqor100337d4brjh2sm1y', 'cmqibqop3001a7d4bi4mhjlur', 'cmqibqop4001c7d4bx1u2j48h', 'cmqibqoqz00317d4blspzgid4', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 17:07:42.926', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqor400357d4brl62ibjl', 'cmqibqop3001a7d4bi4mhjlur', 'cmqibqopa001i7d4bw8d5ptdb', 'cmqibqoqz00317d4blspzgid4', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-17 17:07:42.928', NULL, NULL, NULL, 'pending', false, 0.68);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqor500377d4boy1qaz9g', 'cmqibqop3001a7d4bi4mhjlur', 'cmqibqop8001g7d4bagsjby24', 'cmqibqoqz00317d4blspzgid4', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', '2026-06-17 17:07:42.93', NULL, NULL, NULL, 'pending', false, 0.78);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqor9003b7d4bqilra1w0', 'cmqibqopr001z7d4bzigqewwe', 'cmqibqopt00217d4b6hxmdk7u', 'cmqibqor700397d4bqxgc3v3v', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.934', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqibqorc003d7d4b9wun6iix', 'cmqibqopr001z7d4bzigqewwe', 'cmqibqopw00257d4by5d9qu77', 'cmqibqor700397d4bqxgc3v3v', 2, 'structured', '2', 'Describe the path of a nerve impulse in a reflex arc.', '[]', 'Receptor → sensory neurone → relay neurone → motor neurone → effector.', 'Correct sequence (3m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-17 17:07:42.937', NULL, NULL, NULL, 'pending', false, 0.68);


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqibqoue003l7d4bek7gnuou', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-17 17:07:43.047');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqibqoyd004i7d4bbat4oq6t', 'Siti Nurhaliza', 'siti@student.spm.my', 5, '2026-06-17 17:07:43.189');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqibqp26005f7d4bqynfw55s', 'Kumar Raj', 'kumar@student.spm.my', 4, '2026-06-17 17:07:43.326');
INSERT INTO public."Student" (id, name, email, form, "createdAt") VALUES ('cmqibqp75006e7d4b4z76mnw5', 'Mei Ling', 'meiling@student.spm.my', 5, '2026-06-17 17:07:43.505');


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqoxu00477d4bk1k0z442', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqopz00277d4bgrjr73gw', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-10 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqoxz00497d4bc1kbmdq5', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqoqj002n7d4bvegrhoki', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-11 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqoy2004b7d4b7teh18pi', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqopz00277d4bgrjr73gw', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-13 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqoy5004d7d4bhfhxjk84', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqoqj002n7d4bvegrhoki', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-14 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqoy8004f7d4bs58bkl2f', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqopz00277d4bgrjr73gw', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-16 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp1h00507d4bqqfqo4cz', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqoq200297d4bfw6z1iqb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-07 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp1l00527d4biftu6cwe', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqoqj002n7d4bvegrhoki', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-08 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp1o00547d4bn4055s2l', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqoqa002f7d4byton4n24', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-10 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp1r00567d4bzw71xfg7', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqopz00277d4bgrjr73gw', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-11 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp1v00587d4bop4pewr8', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqoqh002l7d4bgim7j4lj', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-13 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp1z005a7d4bz5cjz2o5', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqoq7002d7d4b8kasevn5', 'Jawapan contoh pelajar.', 10, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-14 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp22005c7d4b33p39a7s', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqoqx002z7d4bijtds98w', 'Jawapan contoh pelajar.', 21, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-16 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6d005v7d4bsm5nxzqm', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-04 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6g005x7d4b8vfkuf7k', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-05 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6l005z7d4bacta1uos', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-07 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6o00617d4b33u7n7b8', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-08 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6q00637d4bd8phenqc', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-10 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6t00657d4bg737bhxk', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-11 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6w00677d4b0s0818ai', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-13 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp6z00697d4b7cfx3vw1', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-14 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqp71006b7d4b50isp16z', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoqf002j7d4bxmtpdkna', 'Jawapan contoh pelajar.', 3, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-16 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpa5006u7d4by61umpog', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoq7002d7d4b8kasevn5', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-01 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpa8006w7d4bbvblrzb0', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqopz00277d4bgrjr73gw', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-02 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpab006y7d4buxyqoaa5', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoqs002v7d4bs0od2k2s', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-04 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpae00707d4bh0cspgxb', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoql002p7d4bfcvkuxrd', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-05 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpah00727d4b6tjues7j', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoq200297d4bfw6z1iqb', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-07 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpaj00747d4bb3moetbt', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoqv002x7d4bvs3jx153', 'Jawapan contoh pelajar.', 23, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-08 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpam00767d4bz7dbt1ia', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoqn002r7d4byoqnggbv', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-10 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpao00787d4b25tfi3uo', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoq5002b7d4bdq68okx4', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-11 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpar007a7d4bfnmofpdi', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoqx002z7d4bijtds98w', 'Jawapan contoh pelajar.', 35, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-13 05:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpau007c7d4bugxc0yqn', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoqp002t7d4bjw4uocj6', 'Jawapan contoh pelajar.', 9, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-14 17:07:43.046');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqibqpax007e7d4b04rkq3nu', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqoq7002d7d4b8kasevn5', 'Jawapan contoh pelajar.', 16, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-16 05:07:43.046');


--
-- Data for Name: Enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqowz003p7d4bgxboomzl', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqonk00007d4bypb4qla8', 'active', '2026-06-17 17:07:43.14');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqox4003r7d4ba7blwwmg', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqoou00117d4buytmwdao', 'active', '2026-06-17 17:07:43.144');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqox8003t7d4bxnqu21be', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqopb001j7d4bhwwigxdx', 'active', '2026-06-17 17:07:43.148');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqoxa003v7d4bw9vwnki2', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqopj001s7d4brkvs9wky', 'active', '2026-06-17 17:07:43.151');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqoxd003x7d4btdfi9ocu', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqopr001z7d4bzigqewwe', 'active', '2026-06-17 17:07:43.154');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqoxg003z7d4bysith4mw', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqood000j7d4bv563ftzx', 'active', '2026-06-17 17:07:43.156');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqoxi00417d4bs3ew64tw', 'cmqibqoue003l7d4bek7gnuou', 'cmqibqool000s7d4bg1dgcyyx', 'active', '2026-06-17 17:07:43.159');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp0w004m7d4brjvx8wxo', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqonk00007d4bypb4qla8', 'active', '2026-06-17 17:07:43.281');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp10004o7d4bucbj9eqw', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqood000j7d4bv563ftzx', 'active', '2026-06-17 17:07:43.284');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp13004q7d4b2trfkqpz', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqool000s7d4bg1dgcyyx', 'active', '2026-06-17 17:07:43.288');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp16004s7d4biqxbm3ei', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqoou00117d4buytmwdao', 'active', '2026-06-17 17:07:43.29');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp19004u7d4blypnlh1o', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqop3001a7d4bi4mhjlur', 'active', '2026-06-17 17:07:43.293');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp1b004w7d4by5xtyavi', 'cmqibqoyd004i7d4bbat4oq6t', 'cmqibqopb001j7d4bhwwigxdx', 'active', '2026-06-17 17:07:43.296');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp53005j7d4br6xpjskz', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqoou00117d4buytmwdao', 'active', '2026-06-17 17:07:43.431');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp57005l7d4b512hhfu9', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqop3001a7d4bi4mhjlur', 'active', '2026-06-17 17:07:43.435');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp5a005n7d4breqase14', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqopb001j7d4bhwwigxdx', 'active', '2026-06-17 17:07:43.439');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp5d005p7d4bg81ca159', 'cmqibqp26005f7d4bqynfw55s', 'cmqibqopj001s7d4brkvs9wky', 'active', '2026-06-17 17:07:43.442');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp9n006i7d4bmg5431u2', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqonk00007d4bypb4qla8', 'active', '2026-06-17 17:07:43.596');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp9r006k7d4bfntc1bmq', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqood000j7d4bv563ftzx', 'active', '2026-06-17 17:07:43.599');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp9t006m7d4birngyl6y', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqool000s7d4bg1dgcyyx', 'active', '2026-06-17 17:07:43.602');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqp9x006o7d4bbdqtbbke', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqopr001z7d4bzigqewwe', 'active', '2026-06-17 17:07:43.606');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqibqpa0006q7d4bgnbtm7qb', 'cmqibqp75006e7d4b4z76mnw5', 'cmqibqopj001s7d4brkvs9wky', 'active', '2026-06-17 17:07:43.608');


--
-- Data for Name: KnowledgeDoc; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqibqore003f7d4bs4wuer1g', 'Photosynthesis — key concepts', 'cmqibqopr001z7d4bzigqewwe', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-17 17:07:42.939');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqibqorh003h7d4b8a1u45jk', 'Acids, bases & salts — essentials', 'cmqibqopj001s7d4brkvs9wky', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-17 17:07:42.941');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqibqori003j7d4b345ytt7w', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqibqonk00007d4bypb4qla8', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-17 17:07:42.943');


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqibqoxl00437d4bq8fbkucm', 'cmqibqoue003l7d4bek7gnuou', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-12 17:07:43.046');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqibqoxo00457d4bsr1v0bka', 'cmqibqoue003l7d4bek7gnuou', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-07 17:07:43.046');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqibqp1e004y7d4ba99i88ju', 'cmqibqoyd004i7d4bbat4oq6t', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-07 17:07:43.046');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqibqp5g005r7d4byoiizbgj', 'cmqibqp26005f7d4bqynfw55s', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-02 17:07:43.046');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqibqp69005t7d4btx0x1evs', 'cmqibqp26005f7d4bqynfw55s', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-05 17:07:43.046');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqibqpa2006s7d4bj6r9i1gq', 'cmqibqp75006e7d4b4z76mnw5', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-28 17:07:43.046');


--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqibqoya004h7d4bo7040b71', 'cmqibqoue003l7d4bek7gnuou', NULL, 1200, 5, '2026-06-17 17:07:43.186');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqibqp24005e7d4b0d5xgc4z', 'cmqibqoyd004i7d4bbat4oq6t', NULL, 1800, 7, '2026-06-17 17:07:43.325');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqibqp73006d7d4b6dlmzwt0', 'cmqibqp26005f7d4bqynfw55s', NULL, 2400, 9, '2026-06-17 17:07:43.504');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqibqpay007g7d4b2ax9sk2k', 'cmqibqp75006e7d4b4z76mnw5', NULL, 3000, 11, '2026-06-17 17:07:43.643');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqibqoua003k7d4b26zkqk4o', 'admin@spm.my', 'Admin Cikgu', 'admin', '1148a17c1b5629cf20f61d0fcb103cb1:991ccb92763db352786f13c830a4668c8a7a249460c5dd98d59c0e0300c6235d0bd642ee4efd0d533d088668475b508eab7bfdccda152e7a798379dc6f9b55fd', NULL, '2026-06-17 17:07:43.043');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqibqoww003n7d4bq5xfuoph', 'ahmad@student.spm.my', 'Ahmad', 'student', 'dd01afa5475bf78690d40a8c33e8729a:a956f34293564f825b3ed13fd4fc998f349bd27eb53df43fec6990d6f57e2eca3f19168904b89ea3c8d7a9466ab4acb962e825acf3af6eb87c978dbc030d6cd5', 'cmqibqoue003l7d4bek7gnuou', '2026-06-17 17:07:43.136');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqibqp0t004k7d4br2hgxlip', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', '4b44c80e325d7ec53f7a5ba9594f61b8:e8ec3081dadba1549dd37950beb8576249302bda1c128680ed0a84f2a28b57bc57f5004c52c29099049d72733a2b3fd61300803f7fc7b44342a124db5c4ce477', 'cmqibqoyd004i7d4bbat4oq6t', '2026-06-17 17:07:43.277');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqibqp4m005h7d4bukplep7s', 'kumar@student.spm.my', 'Kumar Raj', 'student', '70760895a82a2f82fc3e1c44069099da:1173e55e2fb0d7ed27a87ecb2800424837f855779c535243d791235584b30754a68d6b3403df5da0067549e4f3fcf08352e8086f094aa63cf862dd00b2bfc0be', 'cmqibqp26005f7d4bqynfw55s', '2026-06-17 17:07:43.414');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqibqp9k006g7d4bd9o9pt5z', 'meiling@student.spm.my', 'Mei Ling', 'student', '81f19a1c1af1e03f215c776d7aef9436:3388735dd17591ceeb4db61edaccf9d9bee005a1a10f96da506fb5361b45b9bb558ee9d22c2436dc3eb644989626ccabb611d1fe74b468727fb7520e7e92431e', 'cmqibqp75006e7d4b4z76mnw5', '2026-06-17 17:07:43.593');


--
-- PostgreSQL database dump complete
--


