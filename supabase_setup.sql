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
    "school" TEXT,
    "age" INTEGER,
    "state" TEXT,
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

-- CreateTable
CREATE TABLE public."ActivityLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "studentId" TEXT,
    "name" TEXT,
    "role" TEXT,
    "action" TEXT NOT NULL,
    "detail" TEXT,
    "path" TEXT,
    "ip" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ActivityLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE public."PasswordReset" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PasswordReset_pkey" PRIMARY KEY ("id")
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

-- CreateIndex
CREATE INDEX "ActivityLog_createdAt_idx" ON public."ActivityLog"("createdAt");

-- CreateIndex
CREATE INDEX "ActivityLog_studentId_idx" ON public."ActivityLog"("studentId");

-- CreateIndex
CREATE INDEX "ActivityLog_action_idx" ON public."ActivityLog"("action");

-- CreateIndex
CREATE UNIQUE INDEX "PasswordReset_token_key" ON public."PasswordReset"("token");

-- CreateIndex
CREATE INDEX "PasswordReset_userId_idx" ON public."PasswordReset"("userId");

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

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhub00007d001056mudp', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-18 05:12:17.363');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhv2000j7d0088otsv11', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-18 05:12:17.39');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhvc000s7d001cnxu7ul', 'English', 'English', 'ENG', '#2563eb', '2026-06-18 05:12:17.401');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhvm00117d00c6mndk42', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-18 05:12:17.41');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhvu001a7d00b2ndjo2k', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-18 05:12:17.418');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhw2001j7d00j2igr5u6', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-18 05:12:17.427');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhwb001s7d00e2zz5qs4', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-18 05:12:17.435');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj1mhwi001z7d00gyf8hqzd', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-18 05:12:17.443');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj1mhxl00317d000nv0e4e7', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqj1mhvu001a7d00b2ndjo2k', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 05:12:17.481', '2026-06-18 05:12:17.482');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj1mhxu00397d00cw52lic2', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqj1mhwi001z7d00gyf8hqzd', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 05:12:17.49', '2026-06-18 05:12:17.49');


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhug00027d00ipajy9hy', 'cmqj1mhub00007d001056mudp', 4, 1, 'Kemunculan Tamadun Awal Manusia', '["Mesopotamia","Mesir Purba","Indus","Hwang Ho"]', '2026-06-18 05:12:17.368');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhul00047d00na8ekeh2', 'cmqj1mhub00007d001056mudp', 4, 2, 'Peningkatan Tamadun', '["Yunani","Rom","India","China"]', '2026-06-18 05:12:17.374');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhun00067d00pxdovmn4', 'cmqj1mhub00007d001056mudp', 4, 3, 'Tamadun Awal di Asia Tenggara', '["Kerajaan agraria","Kerajaan maritim"]', '2026-06-18 05:12:17.376');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhup00087d008y6d5pk4', 'cmqj1mhub00007d001056mudp', 4, 5, 'Kerajaan Islam di Madinah', '["Piagam Madinah","Perjanjian Hudaibiyah"]', '2026-06-18 05:12:17.378');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhur000a7d00alkk8xje', 'cmqj1mhub00007d001056mudp', 4, 9, 'Perkembangan di Eropah', '["Renaissance","Revolusi Perindustrian"]', '2026-06-18 05:12:17.38');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhut000c7d00zetan3mp', 'cmqj1mhub00007d001056mudp', 5, 1, 'Kemunculan & Perkembangan Nasionalisme di Asia Tenggara', '["Imperialisme Barat","Gerakan nasionalis"]', '2026-06-18 05:12:17.382');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhuv000e7d001n7gvhrq', 'cmqj1mhub00007d001056mudp', 5, 2, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Faktor kemunculan","Akhbar & majalah"]', '2026-06-18 05:12:17.384');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhuy000g7d007p3wv3p3', 'cmqj1mhub00007d001056mudp', 5, 5, 'Pembinaan Negara dan Bangsa Yang Merdeka', '["Pakatan Murni","Kemerdekaan 1957"]', '2026-06-18 05:12:17.386');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhv0000i7d008nke6jew', 'cmqj1mhub00007d001056mudp', 5, 7, 'Sistem Pemerintahan dan Pentadbiran Negara', '["Raja Berperlembagaan","Demokrasi Berparlimen"]', '2026-06-18 05:12:17.388');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhv3000l7d001jn3mywz', 'cmqj1mhv2000j7d0088otsv11', 4, 1, 'Karangan', '["Karangan berformat","Karangan tidak berformat"]', '2026-06-18 05:12:17.392');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhv5000n7d00nhn1i4gh', 'cmqj1mhv2000j7d0088otsv11', 4, 2, 'Pemahaman & Rumusan', '["Rumusan","Soalan pemahaman"]', '2026-06-18 05:12:17.394');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhv7000p7d00ua1673dg', 'cmqj1mhv2000j7d0088otsv11', 5, 3, 'Tatabahasa', '["Kata","Frasa","Ayat"]', '2026-06-18 05:12:17.396');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhv9000r7d00qtzqofur', 'cmqj1mhv2000j7d0088otsv11', 5, 4, 'Komponen Sastera (KOMSAS)', '["Novel","Sajak","Cerpen"]', '2026-06-18 05:12:17.398');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhve000u7d00krbidpjb', 'cmqj1mhvc000s7d001cnxu7ul', 4, 1, 'Reading Comprehension', '["Skimming","Scanning","Inference"]', '2026-06-18 05:12:17.402');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvg000w7d0023q9ugfb', 'cmqj1mhvc000s7d001cnxu7ul', 4, 2, 'Continuous Writing', '["Narrative","Descriptive","Argumentative"]', '2026-06-18 05:12:17.404');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvh000y7d00269q7ozl', 'cmqj1mhvc000s7d001cnxu7ul', 5, 3, 'Grammar in Use', '["Tenses","Subject-verb agreement"]', '2026-06-18 05:12:17.406');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvj00107d00oav8qvfn', 'cmqj1mhvc000s7d001cnxu7ul', 5, 4, 'Literature', '["Poem","Short story","Novel"]', '2026-06-18 05:12:17.407');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvn00137d00n2s2knrz', 'cmqj1mhvm00117d00c6mndk42', 4, 1, 'Quadratic Functions & Equations', '["Roots","Discriminant","Graphs"]', '2026-06-18 05:12:17.412');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvp00157d007pep9r4j', 'cmqj1mhvm00117d00c6mndk42', 4, 3, 'Logarithms & Indices', '["Laws of indices","Laws of logarithms"]', '2026-06-18 05:12:17.413');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvr00177d00ev31ohoa', 'cmqj1mhvm00117d00c6mndk42', 5, 5, 'Probability', '["Combined events","Mutually exclusive"]', '2026-06-18 05:12:17.415');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvs00197d008ygv6hui', 'cmqj1mhvm00117d00c6mndk42', 5, 7, 'Statistics', '["Dispersion","Standard deviation"]', '2026-06-18 05:12:17.416');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvv001c7d00ln5ekkyz', 'cmqj1mhvu001a7d00b2ndjo2k', 4, 1, 'Functions', '["Composite functions","Inverse functions"]', '2026-06-18 05:12:17.42');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvx001e7d009jr9ygn1', 'cmqj1mhvu001a7d00b2ndjo2k', 4, 5, 'Differentiation', '["First derivative","Rates of change"]', '2026-06-18 05:12:17.421');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhvy001g7d00csw0igo8', 'cmqj1mhvu001a7d00b2ndjo2k', 5, 3, 'Integration', '["Indefinite","Definite","Area under curve"]', '2026-06-18 05:12:17.423');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhw0001i7d004foxx666', 'cmqj1mhvu001a7d00b2ndjo2k', 5, 6, 'Permutations & Combinations', '["nPr","nCr"]', '2026-06-18 05:12:17.424');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhw4001l7d00dt3a9p6z', 'cmqj1mhw2001j7d00j2igr5u6', 4, 2, 'Force and Motion', '["Newton''s laws","Momentum"]', '2026-06-18 05:12:17.428');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhw6001n7d00kjswo0vw', 'cmqj1mhw2001j7d00j2igr5u6', 4, 4, 'Heat', '["Specific heat capacity","Latent heat"]', '2026-06-18 05:12:17.43');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhw7001p7d004m5qyb5z', 'cmqj1mhw2001j7d00j2igr5u6', 5, 2, 'Electricity', '["Ohm''s law","Series & parallel"]', '2026-06-18 05:12:17.432');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhw9001r7d00haophly8', 'cmqj1mhw2001j7d00j2igr5u6', 5, 4, 'Electronics', '["Semiconductors","Logic gates"]', '2026-06-18 05:12:17.433');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhwc001u7d00miw6e33k', 'cmqj1mhwb001s7d00e2zz5qs4', 4, 3, 'Chemical Formulae & Equations', '["Mole concept","Empirical formula"]', '2026-06-18 05:12:17.437');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhwe001w7d00xp21cy8c', 'cmqj1mhwb001s7d00e2zz5qs4', 4, 6, 'Acids, Bases and Salts', '["pH","Neutralisation","Salts"]', '2026-06-18 05:12:17.439');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhwg001y7d00d17eb7om', 'cmqj1mhwb001s7d00e2zz5qs4', 5, 2, 'Carbon Compounds', '["Hydrocarbons","Alcohols","Esters"]', '2026-06-18 05:12:17.441');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhwk00217d001mjiet7f', 'cmqj1mhwi001z7d00gyf8hqzd', 4, 2, 'Cell Structure & Organisation', '["Cell components","Diffusion & osmosis"]', '2026-06-18 05:12:17.444');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhwm00237d00iggdate1', 'cmqj1mhwi001z7d00gyf8hqzd', 4, 6, 'Nutrition', '["Photosynthesis","Human digestion"]', '2026-06-18 05:12:17.446');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj1mhwn00257d00owri9tik', 'cmqj1mhwi001z7d00gyf8hqzd', 5, 3, 'Coordination and Response', '["Nervous system","Hormones"]', '2026-06-18 05:12:17.448');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhwq00277d00d7sl0ubl', 'cmqj1mhub00007d001056mudp', 'cmqj1mhug00027d00ipajy9hy', NULL, 1, 'mcq', '1', 'Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?', '[{"key":"A","text":"Tanah subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi"},{"key":"C","text":"Perlombongan bijih timah"},{"key":"D","text":"Hutan tebal"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-18 05:12:17.45', 'Curated seed content', '2026-06-18 05:12:17.449', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhwv00297d00rs7pkltj', 'cmqj1mhub00007d001056mudp', 'cmqj1mhup00087d008y6d5pk4', NULL, 1, 'mcq', '2', 'Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum"},{"key":"B","text":"Menyekat perdagangan"},{"key":"C","text":"Menghapus perhambaan"},{"key":"D","text":"Mewajibkan satu agama"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-18 05:12:17.455', 'Curated seed content', '2026-06-18 05:12:17.454', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhwx002b7d00kj3u9kws', 'cmqj1mhub00007d001056mudp', 'cmqj1mhun00067d00pxdovmn4', NULL, 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.', '1 markah setiap ciri (maks 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-18 05:12:17.457', 'Curated seed content', '2026-06-18 05:12:17.457', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhwz002d7d00ttkxeaww', 'cmqj1mhub00007d001056mudp', 'cmqj1mhuy000g7d007p3wv3p3', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-18 05:12:17.459', 'Curated seed content', '2026-06-18 05:12:17.459', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhx1002f7d005rtcuimp', 'cmqj1mhvm00117d00c6mndk42', 'cmqj1mhvn00137d00n2s2knrz', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.462', 'Curated seed content', '2026-06-18 05:12:17.461', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhx3002h7d00qeoq5wt5', 'cmqj1mhvm00117d00c6mndk42', 'cmqj1mhvr00177d00ev31ohoa', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.464', 'Curated seed content', '2026-06-18 05:12:17.463', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhx5002j7d00exy3q4vc', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhvx001e7d009jr9ygn1', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.465', 'Curated seed content', '2026-06-18 05:12:17.465', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhx7002l7d00mru6zi3j', 'cmqj1mhw2001j7d00j2igr5u6', 'cmqj1mhw4001l7d00dt3a9p6z', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.467', 'Curated seed content', '2026-06-18 05:12:17.466', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxa002n7d00s3txuhoi', 'cmqj1mhw2001j7d00j2igr5u6', 'cmqj1mhw6001n7d00kjswo0vw', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.47', 'Curated seed content', '2026-06-18 05:12:17.469', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxb002p7d00h3sm6bug', 'cmqj1mhwb001s7d00e2zz5qs4', 'cmqj1mhwe001w7d00xp21cy8c', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-18 05:12:17.472', 'Curated seed content', '2026-06-18 05:12:17.471', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxd002r7d00f75zaj2i', 'cmqj1mhwb001s7d00e2zz5qs4', 'cmqj1mhwe001w7d00xp21cy8c', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', '2026-06-18 05:12:17.474', 'Curated seed content', '2026-06-18 05:12:17.473', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxf002t7d00dztklxww', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwm00237d00iggdate1', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.475', 'Curated seed content', '2026-06-18 05:12:17.474', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxh002v7d00easl76d9', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwk00217d001mjiet7f', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.477', 'Curated seed content', '2026-06-18 05:12:17.476', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxi002x7d00165bcb64', 'cmqj1mhvc000s7d001cnxu7ul', 'cmqj1mhvg000w7d0023q9ugfb', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.479', 'Curated seed content', '2026-06-18 05:12:17.478', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxk002z7d00dpg5o4pd', 'cmqj1mhv2000j7d0088otsv11', 'cmqj1mhv3000l7d001jn3mywz', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-18 05:12:17.48', 'Curated seed content', '2026-06-18 05:12:17.479', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxp00337d00sj9f843k', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhvv001c7d00ln5ekkyz', 'cmqj1mhxl00317d000nv0e4e7', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-18 05:12:17.485', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxr00357d000w1nwfdt', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhw0001i7d004foxx666', 'cmqj1mhxl00317d000nv0e4e7', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-18 05:12:17.487', NULL, NULL, NULL, 'pending', false, 0.68);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxs00377d00jucvslo3', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhvy001g7d00csw0igo8', 'cmqj1mhxl00317d000nv0e4e7', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', '2026-06-18 05:12:17.489', NULL, NULL, NULL, 'pending', false, 0.78);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxw003b7d00ipohd4q9', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwk00217d001mjiet7f', 'cmqj1mhxu00397d00cw52lic2', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.492', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj1mhxy003d7d005wtxfawh', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwn00257d00owri9tik', 'cmqj1mhxu00397d00cw52lic2', 2, 'structured', '2', 'Describe the path of a nerve impulse in a reflex arc.', '[]', 'Receptor → sensory neurone → relay neurone → motor neurone → effector.', 'Correct sequence (3m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 05:12:17.494', NULL, NULL, NULL, 'pending', false, 0.68);


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mi0s003l7d00rj57198b', 'Vikhash', 'vikhash@student.spm.my', 5, '2026-06-18 05:12:17.596', '2026-06-18 05:12:17.595', true, '+60123456789', NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mi4k004k7d00jsul4gyy', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-18 05:12:17.732', '2026-06-18 05:12:17.731', true, NULL, NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mi84005j7d005ou9vuzq', 'Siti Nurhaliza', 'siti@student.spm.my', 5, '2026-06-18 05:12:17.861', '2026-06-18 05:12:17.86', true, NULL, NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mibt006m7d003g92pw9f', 'Kumar Raj', 'kumar@student.spm.my', 4, '2026-06-18 05:12:17.993', '2026-06-18 05:12:17.993', true, NULL, NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mifl007n7d00lnizxlp3', 'Mei Ling', 'meiling@student.spm.my', 5, '2026-06-18 05:12:18.129', '2026-06-18 05:12:18.128', true, NULL, NULL, NULL, NULL);


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi4400497d00uwmn0mtx', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhwq00277d00d7sl0ubl', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-10 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi48004b7d008v2oo8nb', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-12 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi4b004d7d00u5wchhs9', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhxk002z7d00dpg5o4pd', 'Jawapan contoh pelajar.', 22, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-13 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi4d004f7d00z4wl1ae8', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhx5002j7d00exy3q4vc', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-15 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi4g004h7d00rgnkp2ew', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhxi002x7d00165bcb64', 'Jawapan contoh pelajar.', 13, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-16 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi7j00547d005hchxohk', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhwv00297d00rs7pkltj', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-07 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi7m00567d00ohqh1hj0', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhxb002p7d00h3sm6bug', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-09 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi7o00587d00d45ywwvy', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhwv00297d00rs7pkltj', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-10 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi7r005a7d00atslmvu3', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhxb002p7d00h3sm6bug', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-12 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi7u005c7d004lxqso2b', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhwv00297d00rs7pkltj', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-13 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi7x005e7d00tx8et1nc', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhxb002p7d00h3sm6bug', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-15 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mi80005g7d00qnbfr3on', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhwv00297d00rs7pkltj', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-16 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mib300637d00iy5jpwlv', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhwx002b7d00kj3u9kws', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-04 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mib600657d00s3ykavy4', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhxi002x7d00165bcb64', 'Jawapan contoh pelajar.', 26, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-06 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mib800677d00nmukvru2', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhx3002h7d00qeoq5wt5', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-07 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mibb00697d003rdv5yv6', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhwv00297d00rs7pkltj', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-09 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mibf006b7d00mdayaos1', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhxa002n7d00s3txuhoi', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-10 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mibi006d7d00d18czby5', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhx1002f7d005rtcuimp', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-12 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mibl006f7d00nuedeuum', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhwq00277d00d7sl0ubl', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-13 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mibn006h7d00zpzqo2lw', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-15 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mibq006j7d00bw311h4n', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhwz002d7d00ttkxeaww', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-16 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mien00707d005690sdgo', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-01 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miet00727d00k5oaky74', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-03 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miev00747d00d8u5yi70', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-04 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miey00767d00cf277ac6', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-06 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mif100787d00l7pe9k1s', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-07 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mif4007a7d00ij0jc3in', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-09 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mif6007c7d00gbawwotd', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-10 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mif9007e7d006q4jcery', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-12 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mifc007g7d001gj7x6dv', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-13 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mife007i7d00eq786bsx', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-15 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mifh007k7d00ucnpbkv1', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhx7002l7d00mru6zi3j', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-16 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miif00857d00uhppnm7n', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxb002p7d00h3sm6bug', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-05-29 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miii00877d00r2nhf959', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhwv00297d00rs7pkltj', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-05-31 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miil00897d00omd8izpo', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxi002x7d00165bcb64', 'Jawapan contoh pelajar.', 19, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-01 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miio008b7d00eic4412h', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxd002r7d00f75zaj2i', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-03 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miir008d7d00ppkdjim8', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhwx002b7d00kj3u9kws', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-04 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miit008f7d00d0yw3a65', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxk002z7d00dpg5o4pd', 'Jawapan contoh pelajar.', 14, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-06 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1miix008h7d00u0h6g11p', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxf002t7d00dztklxww', 'Jawapan contoh pelajar.', 5, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-07 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mij0008j7d00idiedn1k', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhwz002d7d00ttkxeaww', 'Jawapan contoh pelajar.', 12, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-09 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mij3008l7d00kyr6d91k', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhwq00277d00d7sl0ubl', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-10 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mij6008n7d00d13s51l0', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxh002v7d00easl76d9', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-12 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mij8008p7d00powyv1ic', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxb002p7d00h3sm6bug', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-13 17:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mijb008r7d00160uqzha', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhwv00297d00rs7pkltj', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 280, '2026-06-15 05:12:17.595');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj1mije008t7d00of6vd4mc', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhxi002x7d00165bcb64', 'Jawapan contoh pelajar.', 14, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 300, '2026-06-16 17:12:17.595');


--
-- Data for Name: Enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi36003p7d00lqyfjyz7', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhub00007d001056mudp', 'active', '2026-06-18 05:12:17.682');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi3a003r7d00ndoynqu0', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhv2000j7d0088otsv11', 'active', '2026-06-18 05:12:17.686');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi3d003t7d00rpuzj2na', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhvc000s7d001cnxu7ul', 'active', '2026-06-18 05:12:17.689');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi3f003v7d00q5ctahs6', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhvm00117d00c6mndk42', 'active', '2026-06-18 05:12:17.692');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi3i003x7d00dbucdju6', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhvu001a7d00b2ndjo2k', 'active', '2026-06-18 05:12:17.694');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi3k003z7d00gnnw5eia', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhw2001j7d00j2igr5u6', 'active', '2026-06-18 05:12:17.696');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi3o00417d00bjqbrvth', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhwb001s7d00e2zz5qs4', 'active', '2026-06-18 05:12:17.7');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi3q00437d005wgm2so9', 'cmqj1mi0s003l7d00rj57198b', 'cmqj1mhwi001z7d00gyf8hqzd', 'active', '2026-06-18 05:12:17.702');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi6x004o7d004xszilyi', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhub00007d001056mudp', 'active', '2026-06-18 05:12:17.817');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi70004q7d0085k2erq9', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhvm00117d00c6mndk42', 'active', '2026-06-18 05:12:17.82');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi72004s7d0038qp1w07', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhw2001j7d00j2igr5u6', 'active', '2026-06-18 05:12:17.823');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi76004u7d00qdt51cdz', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhwb001s7d00e2zz5qs4', 'active', '2026-06-18 05:12:17.827');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi79004w7d00p9bhy7lq', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhwi001z7d00gyf8hqzd', 'active', '2026-06-18 05:12:17.829');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi7c004y7d00nm3ldqx8', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhv2000j7d0088otsv11', 'active', '2026-06-18 05:12:17.832');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mi7e00507d00i75hhs4o', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj1mhvc000s7d001cnxu7ul', 'active', '2026-06-18 05:12:17.834');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1miai005n7d00sn1oo234', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhub00007d001056mudp', 'active', '2026-06-18 05:12:17.946');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mial005p7d00xmxecmjc', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhv2000j7d0088otsv11', 'active', '2026-06-18 05:12:17.949');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1miao005r7d00njnjne4o', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhvc000s7d001cnxu7ul', 'active', '2026-06-18 05:12:17.952');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1miaq005t7d0052smboy8', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhvm00117d00c6mndk42', 'active', '2026-06-18 05:12:17.955');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1miat005v7d004vpxt4fd', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhvu001a7d00b2ndjo2k', 'active', '2026-06-18 05:12:17.957');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1miaw005x7d008yiat595', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj1mhw2001j7d00j2igr5u6', 'active', '2026-06-18 05:12:17.96');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1miea006q7d006w3czjj9', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhvm00117d00c6mndk42', 'active', '2026-06-18 05:12:18.082');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mied006s7d00lm8ylet1', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhvu001a7d00b2ndjo2k', 'active', '2026-06-18 05:12:18.085');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mief006u7d00mduta3m7', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhw2001j7d00j2igr5u6', 'active', '2026-06-18 05:12:18.088');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mieh006w7d00cte30jzr', 'cmqj1mibt006m7d003g92pw9f', 'cmqj1mhwb001s7d00e2zz5qs4', 'active', '2026-06-18 05:12:18.09');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mihy007r7d00pha94hjl', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhub00007d001056mudp', 'active', '2026-06-18 05:12:18.214');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mii1007t7d00x27kmki6', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhv2000j7d0088otsv11', 'active', '2026-06-18 05:12:18.217');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mii3007v7d00lyuciamj', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhvc000s7d001cnxu7ul', 'active', '2026-06-18 05:12:18.22');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mii6007x7d00l9q2iw3c', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhwi001z7d00gyf8hqzd', 'active', '2026-06-18 05:12:18.222');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqj1mii9007z7d00c6nmy8op', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj1mhwb001s7d00e2zz5qs4', 'active', '2026-06-18 05:12:18.225');


--
-- Data for Name: KnowledgeDoc; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj1mhy0003f7d00nl55prki', 'Photosynthesis — key concepts', 'cmqj1mhwi001z7d00gyf8hqzd', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-18 05:12:17.496');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj1mhy2003h7d00vke5w7ez', 'Acids, bases & salts — essentials', 'cmqj1mhwb001s7d00e2zz5qs4', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-18 05:12:17.498');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj1mhy4003j7d00cgyno7xe', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqj1mhub00007d001056mudp', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-18 05:12:17.5');


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1mi3u00457d00p7hgtof8', 'cmqj1mi0s003l7d00rj57198b', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-13 05:12:17.595');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1mi4000477d00ghyczc5h', 'cmqj1mi0s003l7d00rj57198b', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-08 05:12:17.595');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1mi7g00527d00h0hf9phb', 'cmqj1mi4k004k7d00jsul4gyy', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-08 05:12:17.595');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1miay005z7d001u7l53k6', 'cmqj1mi84005j7d005ou9vuzq', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-03 05:12:17.595');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1mib000617d00p2o6gx2v', 'cmqj1mi84005j7d005ou9vuzq', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-06 05:12:17.595');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1miek006y7d00r17c2lbb', 'cmqj1mibt006m7d003g92pw9f', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-29 05:12:17.595');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1miib00817d00jty4pv3r', 'cmqj1mifl007n7d00lnizxlp3', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-05-24 05:12:17.595');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj1miid00837d00y6nwu8p0', 'cmqj1mifl007n7d00lnizxlp3', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-04 05:12:17.595');


--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mi4i004j7d0025l10lqu', 'cmqj1mi0s003l7d00rj57198b', NULL, 1200, 5, '2026-06-18 05:12:17.73');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mi81005i7d00q4bo1wcv', 'cmqj1mi4k004k7d00jsul4gyy', NULL, 1800, 7, '2026-06-18 05:12:17.858');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mibr006l7d005ic6diwn', 'cmqj1mi84005j7d005ou9vuzq', NULL, 2400, 9, '2026-06-18 05:12:17.992');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mifj007m7d00shm0wlll', 'cmqj1mibt006m7d003g92pw9f', NULL, 3000, 11, '2026-06-18 05:12:18.127');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mijf008v7d0066awun6i', 'cmqj1mifl007n7d00lnizxlp3', NULL, 3600, 13, '2026-06-18 05:12:18.268');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mi0o003k7d00tah479c8', 'admin@spm.my', 'Admin Cikgu', 'admin', '1cfbc792eeb891171dd37fc1a4906791:8c546400d114ac2d0847ecc299b0b9e53abe9bd8e231bfd4efcf70aa33c98889ef240a1c34d3aba10e89490aaec01ec40cba0515f5d285dbd94f684d124e5402', NULL, '2026-06-18 05:12:17.593');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mi33003n7d00wnugwk2r', 'vikhash@student.spm.my', 'Vikhash', 'student', 'c11ada2ba96c1bca124ed231ac882a00:f05af40a57c5843b81ab7885ab29aa7120f4188d450df379097c7231b06ef6e98b251550b3a851e2856a172c52fae4a0bf6d13d299b54e039cc931f5fb02332f', 'cmqj1mi0s003l7d00rj57198b', '2026-06-18 05:12:17.679');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mi6u004m7d00ly751rcq', 'ahmad@student.spm.my', 'Ahmad', 'student', 'af3224c0f70473bdb64ef15f7cd40edb:28891a2db36fcaac2de71841a0ac78b14ee3f474d8b02651c433ff65deb6cc668a7af373a91762f99304893841c85531d2815bbf75d9fe33334d5a418cebd922', 'cmqj1mi4k004k7d00jsul4gyy', '2026-06-18 05:12:17.814');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1miaf005l7d00ld52zwnd', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', 'c062e96b99e0b09ffbbcb933bd36e8c0:eacf74eb4fc24467ff27c099495d3d232a6e53ab6d35e6bfc6d109e34885d4a878880b826b131fa2a109134c0a79895242807afb619da4363c05d24081fa3f3a', 'cmqj1mi84005j7d005ou9vuzq', '2026-06-18 05:12:17.944');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mie7006o7d00dc6or38w', 'kumar@student.spm.my', 'Kumar Raj', 'student', '7ec2614f070d9ceef84137b760191c90:9c402c6940dd06bf69469d660aaf6b71fa26c9ba0a6061ab82d07d69b8659809cb411126af2c240231f0d4149d92f438a5dbaf2e28a54b984f00bf60b88649e0', 'cmqj1mibt006m7d003g92pw9f', '2026-06-18 05:12:18.079');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mihu007p7d004vfvig1z', 'meiling@student.spm.my', 'Mei Ling', 'student', '43a1823d60ea9c2609a647312c5466d7:abf1bec29751d84cbfb8dd63f99f24cad6cdfb93504f115d98546d3b3c075bbe89e1b58b18d137840a524b88ea2bd84080a9497ebadc079e2ad0dc95c4368467', 'cmqj1mifl007n7d00lnizxlp3', '2026-06-18 05:12:18.21');


--
-- PostgreSQL database dump complete
--


