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

-- ===================== SCHEMA =============================
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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ActivityLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ActivityLog" (
    id text NOT NULL,
    "userId" text,
    "studentId" text,
    name text,
    role text,
    action text NOT NULL,
    detail text,
    path text,
    ip text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Assignment" (
    id text NOT NULL,
    title text NOT NULL,
    type text DEFAULT 'paper'::text NOT NULL,
    "paperId" text,
    "topicId" text,
    "subjectId" text,
    "dueAt" timestamp(3) without time zone,
    "createdById" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Attempt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Attempt" (
    id text NOT NULL,
    "studentId" text NOT NULL,
    "questionId" text NOT NULL,
    answer text NOT NULL,
    score double precision DEFAULT 0 NOT NULL,
    "maxScore" double precision DEFAULT 1 NOT NULL,
    band text,
    "isCorrect" boolean,
    feedback text,
    "gradedByAi" boolean DEFAULT false NOT NULL,
    "timeSpentSec" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Bookmark; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Bookmark" (
    id text NOT NULL,
    "studentId" text NOT NULL,
    "questionId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Enrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Enrollment" (
    id text NOT NULL,
    "studentId" text NOT NULL,
    "subjectId" text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: GeneratedQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."GeneratedQuestion" (
    id text NOT NULL,
    "topicId" text NOT NULL,
    "questionType" text NOT NULL,
    stem text NOT NULL,
    options text DEFAULT '[]'::text NOT NULL,
    answer text,
    "markingScheme" text,
    rubric text,
    marks integer DEFAULT 1 NOT NULL,
    "isKbat" boolean DEFAULT true NOT NULL,
    "basedOn" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: KnowledgeDoc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."KnowledgeDoc" (
    id text NOT NULL,
    title text NOT NULL,
    "subjectId" text,
    form integer,
    kind text DEFAULT 'note'::text NOT NULL,
    source text,
    content text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    chapter integer,
    language text,
    "sourceKey" text,
    "sourceUrl" text,
    "topicId" text
);


--
-- Name: MockPaper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MockPaper" (
    id text NOT NULL,
    title text NOT NULL,
    "subjectId" text NOT NULL,
    "paperNumber" integer DEFAULT 1 NOT NULL,
    "questionIds" text DEFAULT '[]'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Paper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Paper" (
    id text NOT NULL,
    title text NOT NULL,
    "subjectId" text NOT NULL,
    "paperType" text NOT NULL,
    year integer NOT NULL,
    state text,
    "paperNumber" integer DEFAULT 1 NOT NULL,
    "fileUrl" text,
    "fileName" text,
    "rawText" text,
    "markingScheme" text,
    rubric text,
    status text DEFAULT 'uploaded'::text NOT NULL,
    "categorizedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    language text,
    "sourceKey" text,
    "sourceUrl" text
);


--
-- Name: PasswordReset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PasswordReset" (
    id text NOT NULL,
    "userId" text NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "usedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Payment" (
    id text NOT NULL,
    "studentId" text NOT NULL,
    amount double precision NOT NULL,
    currency text DEFAULT 'MYR'::text NOT NULL,
    method text,
    status text DEFAULT 'paid'::text NOT NULL,
    description text,
    "paidAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: PushSubscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PushSubscription" (
    id text NOT NULL,
    "studentId" text,
    endpoint text NOT NULL,
    p256dh text NOT NULL,
    auth text NOT NULL,
    "userAgent" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Question; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question" (
    id text NOT NULL,
    "subjectId" text NOT NULL,
    "topicId" text,
    "paperId" text,
    "paperNumber" integer DEFAULT 1 NOT NULL,
    "questionType" text NOT NULL,
    number text,
    stem text NOT NULL,
    options text DEFAULT '[]'::text NOT NULL,
    answer text,
    "markingScheme" text,
    rubric text,
    marks integer DEFAULT 1 NOT NULL,
    "isKbat" boolean DEFAULT false NOT NULL,
    subtopic text,
    year integer,
    source text DEFAULT 'past_paper'::text NOT NULL,
    status text DEFAULT 'approved'::text NOT NULL,
    confidence double precision,
    "autoApproved" boolean DEFAULT false NOT NULL,
    "reviewNote" text,
    "reviewedById" text,
    "reviewedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ReviewItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReviewItem" (
    id text NOT NULL,
    "studentId" text NOT NULL,
    "questionId" text NOT NULL,
    box integer DEFAULT 0 NOT NULL,
    "dueAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastScorePct" double precision DEFAULT 0 NOT NULL,
    reps integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Student; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Student" (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    form integer DEFAULT 5 NOT NULL,
    school text,
    age integer,
    state text,
    whatsapp text,
    "pdpaConsent" boolean DEFAULT false NOT NULL,
    "consentAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: StudySession; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."StudySession" (
    id text NOT NULL,
    "studentId" text NOT NULL,
    "subjectId" text,
    "durationSec" integer DEFAULT 0 NOT NULL,
    "questionsDone" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Subject; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Subject" (
    id text NOT NULL,
    name text NOT NULL,
    "nameEn" text,
    code text NOT NULL,
    color text DEFAULT '#3470f4'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Topic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Topic" (
    id text NOT NULL,
    "subjectId" text NOT NULL,
    form integer NOT NULL,
    chapter integer NOT NULL,
    title text NOT NULL,
    subtopics text DEFAULT '[]'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    role text NOT NULL,
    password text NOT NULL,
    "studentId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Waitlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Waitlist" (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    whatsapp text,
    school text,
    state text,
    note text,
    invited boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ActivityLog ActivityLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActivityLog"
    ADD CONSTRAINT "ActivityLog_pkey" PRIMARY KEY (id);


--
-- Name: Assignment Assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_pkey" PRIMARY KEY (id);


--
-- Name: Attempt Attempt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attempt"
    ADD CONSTRAINT "Attempt_pkey" PRIMARY KEY (id);


--
-- Name: Bookmark Bookmark_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Bookmark"
    ADD CONSTRAINT "Bookmark_pkey" PRIMARY KEY (id);


--
-- Name: Enrollment Enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Enrollment"
    ADD CONSTRAINT "Enrollment_pkey" PRIMARY KEY (id);


--
-- Name: GeneratedQuestion GeneratedQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GeneratedQuestion"
    ADD CONSTRAINT "GeneratedQuestion_pkey" PRIMARY KEY (id);


--
-- Name: KnowledgeDoc KnowledgeDoc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."KnowledgeDoc"
    ADD CONSTRAINT "KnowledgeDoc_pkey" PRIMARY KEY (id);


--
-- Name: MockPaper MockPaper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MockPaper"
    ADD CONSTRAINT "MockPaper_pkey" PRIMARY KEY (id);


--
-- Name: Paper Paper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Paper"
    ADD CONSTRAINT "Paper_pkey" PRIMARY KEY (id);


--
-- Name: PasswordReset PasswordReset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PasswordReset"
    ADD CONSTRAINT "PasswordReset_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: PushSubscription PushSubscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PushSubscription"
    ADD CONSTRAINT "PushSubscription_pkey" PRIMARY KEY (id);


--
-- Name: Question Question_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_pkey" PRIMARY KEY (id);


--
-- Name: ReviewItem ReviewItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReviewItem"
    ADD CONSTRAINT "ReviewItem_pkey" PRIMARY KEY (id);


--
-- Name: Student Student_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Student"
    ADD CONSTRAINT "Student_pkey" PRIMARY KEY (id);


--
-- Name: StudySession StudySession_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudySession"
    ADD CONSTRAINT "StudySession_pkey" PRIMARY KEY (id);


--
-- Name: Subject Subject_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Subject"
    ADD CONSTRAINT "Subject_pkey" PRIMARY KEY (id);


--
-- Name: Topic Topic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Waitlist Waitlist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Waitlist"
    ADD CONSTRAINT "Waitlist_pkey" PRIMARY KEY (id);


--
-- Name: ActivityLog_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ActivityLog_action_idx" ON public."ActivityLog" USING btree (action);


--
-- Name: ActivityLog_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ActivityLog_createdAt_idx" ON public."ActivityLog" USING btree ("createdAt");


--
-- Name: ActivityLog_studentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ActivityLog_studentId_idx" ON public."ActivityLog" USING btree ("studentId");


--
-- Name: Assignment_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Assignment_createdAt_idx" ON public."Assignment" USING btree ("createdAt");


--
-- Name: Attempt_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Attempt_questionId_idx" ON public."Attempt" USING btree ("questionId");


--
-- Name: Attempt_studentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Attempt_studentId_idx" ON public."Attempt" USING btree ("studentId");


--
-- Name: Bookmark_studentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Bookmark_studentId_idx" ON public."Bookmark" USING btree ("studentId");


--
-- Name: Bookmark_studentId_questionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Bookmark_studentId_questionId_key" ON public."Bookmark" USING btree ("studentId", "questionId");


--
-- Name: Enrollment_studentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Enrollment_studentId_idx" ON public."Enrollment" USING btree ("studentId");


--
-- Name: Enrollment_studentId_subjectId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Enrollment_studentId_subjectId_key" ON public."Enrollment" USING btree ("studentId", "subjectId");


--
-- Name: GeneratedQuestion_topicId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GeneratedQuestion_topicId_idx" ON public."GeneratedQuestion" USING btree ("topicId");


--
-- Name: KnowledgeDoc_sourceKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "KnowledgeDoc_sourceKey_key" ON public."KnowledgeDoc" USING btree ("sourceKey");


--
-- Name: KnowledgeDoc_subjectId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "KnowledgeDoc_subjectId_idx" ON public."KnowledgeDoc" USING btree ("subjectId");


--
-- Name: Paper_paperType_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Paper_paperType_idx" ON public."Paper" USING btree ("paperType");


--
-- Name: Paper_sourceKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Paper_sourceKey_key" ON public."Paper" USING btree ("sourceKey");


--
-- Name: Paper_subjectId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Paper_subjectId_idx" ON public."Paper" USING btree ("subjectId");


--
-- Name: PasswordReset_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PasswordReset_token_key" ON public."PasswordReset" USING btree (token);


--
-- Name: PasswordReset_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PasswordReset_userId_idx" ON public."PasswordReset" USING btree ("userId");


--
-- Name: Payment_studentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_studentId_idx" ON public."Payment" USING btree ("studentId");


--
-- Name: PushSubscription_endpoint_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PushSubscription_endpoint_key" ON public."PushSubscription" USING btree (endpoint);


--
-- Name: PushSubscription_studentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PushSubscription_studentId_idx" ON public."PushSubscription" USING btree ("studentId");


--
-- Name: Question_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_status_idx" ON public."Question" USING btree (status);


--
-- Name: Question_subjectId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_subjectId_idx" ON public."Question" USING btree ("subjectId");


--
-- Name: Question_topicId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_topicId_idx" ON public."Question" USING btree ("topicId");


--
-- Name: Question_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_year_idx" ON public."Question" USING btree (year);


--
-- Name: ReviewItem_studentId_dueAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ReviewItem_studentId_dueAt_idx" ON public."ReviewItem" USING btree ("studentId", "dueAt");


--
-- Name: ReviewItem_studentId_questionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ReviewItem_studentId_questionId_key" ON public."ReviewItem" USING btree ("studentId", "questionId");


--
-- Name: Student_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Student_email_key" ON public."Student" USING btree (email);


--
-- Name: StudySession_studentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudySession_studentId_idx" ON public."StudySession" USING btree ("studentId");


--
-- Name: Subject_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Subject_code_key" ON public."Subject" USING btree (code);


--
-- Name: Subject_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Subject_name_key" ON public."Subject" USING btree (name);


--
-- Name: Topic_subjectId_form_chapter_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Topic_subjectId_form_chapter_key" ON public."Topic" USING btree ("subjectId", form, chapter);


--
-- Name: Topic_subjectId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Topic_subjectId_idx" ON public."Topic" USING btree ("subjectId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_role_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_role_idx" ON public."User" USING btree (role);


--
-- Name: User_studentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_studentId_key" ON public."User" USING btree ("studentId");


--
-- Name: Waitlist_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Waitlist_createdAt_idx" ON public."Waitlist" USING btree ("createdAt");


--
-- Name: Waitlist_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Waitlist_email_key" ON public."Waitlist" USING btree (email);


--
-- Name: Attempt Attempt_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attempt"
    ADD CONSTRAINT "Attempt_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Attempt Attempt_studentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attempt"
    ADD CONSTRAINT "Attempt_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Bookmark Bookmark_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Bookmark"
    ADD CONSTRAINT "Bookmark_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Bookmark Bookmark_studentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Bookmark"
    ADD CONSTRAINT "Bookmark_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Enrollment Enrollment_studentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Enrollment"
    ADD CONSTRAINT "Enrollment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Enrollment Enrollment_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Enrollment"
    ADD CONSTRAINT "Enrollment_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: GeneratedQuestion GeneratedQuestion_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GeneratedQuestion"
    ADD CONSTRAINT "GeneratedQuestion_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: KnowledgeDoc KnowledgeDoc_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."KnowledgeDoc"
    ADD CONSTRAINT "KnowledgeDoc_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Paper Paper_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Paper"
    ADD CONSTRAINT "Paper_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment Payment_studentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Question Question_paperId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_paperId_fkey" FOREIGN KEY ("paperId") REFERENCES public."Paper"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Question Question_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Question Question_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ReviewItem ReviewItem_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReviewItem"
    ADD CONSTRAINT "ReviewItem_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ReviewItem ReviewItem_studentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReviewItem"
    ADD CONSTRAINT "ReviewItem_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: StudySession StudySession_studentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudySession"
    ADD CONSTRAINT "StudySession_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Topic Topic_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_studentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES public."Student"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--



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
-- Data for Name: ActivityLog; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Assignment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Subject; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdruoo00007dfje2vfvz6p', 'Sejarah', 'History', 'SEJ', '#b45309', '2026-06-18 10:52:22.68');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdrupz00157dfjd7j8vlqf', 'Bahasa Melayu', 'Malay Language', 'BM', '#dc2626', '2026-06-18 10:52:22.727');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdruqh001o7dfjrcz8y1v9', 'English', 'English', 'ENG', '#2563eb', '2026-06-18 10:52:22.746');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdrur100297dfjgo81hkdn', 'Mathematics', 'Mathematics', 'MATE', '#059669', '2026-06-18 10:52:22.766');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdrury003a7dfjgeyjnao3', 'Additional Mathematics', 'Additional Mathematics', 'ADDMATE', '#0d9488', '2026-06-18 10:52:22.798');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdrusw004b7dfj5zh6cgwt', 'Physics', 'Physics', 'FIZ', '#7c3aed', '2026-06-18 10:52:22.833');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdrutl00527dfjapskw877', 'Chemistry', 'Chemistry', 'KIM', '#db2777', '2026-06-18 10:52:22.857');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdruua005t7dfj9q6x1q3q', 'Biology', 'Biology', 'BIO', '#16a34a', '2026-06-18 10:52:22.882');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdruva006y7dfjbogi4oil', 'Pendidikan Islam', 'Islamic Studies', 'PI', '#0f766e', '2026-06-18 10:52:22.919');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdruvw007n7dfj03ndl73f', 'Pendidikan Moral', 'Moral Education', 'PM', '#9333ea', '2026-06-18 10:52:22.941');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdruwa00807dfjqlk706mv', 'Ekonomi', 'Economics', 'EKO', '#ca8a04', '2026-06-18 10:52:22.954');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqjdruwq008d7dfj8fh00ni1', 'Prinsip Perakaunan', 'Principles of Accounting', 'PP', '#0891b2', '2026-06-18 10:52:22.97');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt", language, "sourceKey", "sourceUrl") VALUES ('cmqjdruyd00a57dfj00jxqvhe', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqjdrury003a7dfjgeyjnao3', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 10:52:23.029', '2026-06-18 10:52:23.03', NULL, NULL, NULL);
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt", language, "sourceKey", "sourceUrl") VALUES ('cmqjdruyl00ad7dfjvm8x3tjd', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqjdruua005t7dfj9q6x1q3q', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 10:52:23.037', '2026-06-18 10:52:23.038', NULL, NULL, NULL);


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruot00027dfjwivr25hz', 'cmqjdruoo00007dfje2vfvz6p', 4, 1, 'Warisan Negara Bangsa', '["Ciri negara bangsa","Kesultanan Melayu Melaka","Kedaulatan & jati diri"]', '2026-06-18 10:52:22.685');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruow00047dfjv53r6aoz', 'cmqjdruoo00007dfje2vfvz6p', 4, 2, 'Kebangkitan Nasionalisme', '["Maksud nasionalisme","Faktor kemunculan","Kesedaran kebangsaan"]', '2026-06-18 10:52:22.689');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruoy00067dfjmbfom11l', 'cmqjdruoo00007dfje2vfvz6p', 4, 3, 'Nasionalisme di Malaysia Sehingga Perang Dunia Kedua', '["Gerakan Islah","Akhbar & majalah","Persatuan Melayu"]', '2026-06-18 10:52:22.691');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrup100087dfjwdwdhua2', 'cmqjdruoo00007dfje2vfvz6p', 4, 4, 'Konflik Dunia dan Pendudukan Jepun', '["Perang Dunia Kedua","Pendudukan Jepun","Semangat anti-penjajah"]', '2026-06-18 10:52:22.693');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrup3000a7dfj8cufyzb4', 'cmqjdruoo00007dfje2vfvz6p', 4, 5, 'Era Peralihan Kuasa British (Malayan Union 1946)', '["Malayan Union","Penentangan Melayu","Penubuhan UMNO"]', '2026-06-18 10:52:22.695');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrup4000c7dfjs2l1mltb', 'cmqjdruoo00007dfje2vfvz6p', 4, 6, 'Persekutuan Tanah Melayu 1948', '["Perlembagaan 1948","Kedudukan Raja-Raja Melayu","Kerakyatan"]', '2026-06-18 10:52:22.697');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrup6000e7dfjmtrnq3wn', 'cmqjdruoo00007dfje2vfvz6p', 4, 7, 'Ancaman Komunis dan Perisytiharan Darurat', '["Parti Komunis Malaya","Darurat 1948","Rancangan Briggs"]', '2026-06-18 10:52:22.699');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrup9000g7dfjq17y1aw9', 'cmqjdruoo00007dfje2vfvz6p', 4, 8, 'Usaha ke Arah Kemerdekaan', '["Sistem Ahli","Pakatan Murni","Pilihan Raya 1955"]', '2026-06-18 10:52:22.701');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupb000i7dfjzs97m55s', 'cmqjdruoo00007dfje2vfvz6p', 4, 9, 'Perlembagaan Persekutuan Tanah Melayu 1957', '["Suruhanjaya Reid","Kontrak sosial","Hak istimewa"]', '2026-06-18 10:52:22.703');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupd000k7dfjlbvawqo4', 'cmqjdruoo00007dfje2vfvz6p', 4, 10, 'Pemasyhuran Kemerdekaan', '["31 Ogos 1957","Peranan Tunku Abdul Rahman","Makna kemerdekaan"]', '2026-06-18 10:52:22.705');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupg000m7dfjgvdnhrvn', 'cmqjdruoo00007dfje2vfvz6p', 5, 1, 'Kedaulatan Negara', '["Konsep kedaulatan","Ciri negara berdaulat","Mempertahankan kedaulatan"]', '2026-06-18 10:52:22.709');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupi000o7dfj2f5ehplh', 'cmqjdruoo00007dfje2vfvz6p', 5, 2, 'Perlembagaan Persekutuan', '["Keluhuran perlembagaan","Unsur tradisi","Kebebasan asasi"]', '2026-06-18 10:52:22.711');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupk000q7dfjdanpio1c', 'cmqjdruoo00007dfje2vfvz6p', 5, 3, 'Raja Berperlembagaan dan Demokrasi Berparlimen', '["Yang di-Pertuan Agong","Majlis Raja-Raja","Pengasingan kuasa"]', '2026-06-18 10:52:22.713');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupm000s7dfjshpt97fo', 'cmqjdruoo00007dfje2vfvz6p', 5, 4, 'Sistem Persekutuan', '["Konsep persekutuan","Pembahagian kuasa","Senarai Persekutuan & Negeri"]', '2026-06-18 10:52:22.714');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupo000u7dfjo08787ct', 'cmqjdruoo00007dfje2vfvz6p', 5, 5, 'Pembentukan Malaysia', '["Idea Malaysia","Suruhanjaya Cobbold","Perjanjian Malaysia 1963"]', '2026-06-18 10:52:22.717');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupq000w7dfj8ola95ke', 'cmqjdruoo00007dfje2vfvz6p', 5, 6, 'Cabaran Selepas Pembentukan Malaysia', '["Konfrontasi Indonesia","Tuntutan Filipina","Singapura keluar 1965"]', '2026-06-18 10:52:22.718');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrups000y7dfj57okbnun', 'cmqjdruoo00007dfje2vfvz6p', 5, 7, 'Membina Kesejahteraan Negara', '["Peristiwa 13 Mei 1969","MAGERAN","Rukun Negara & DEB"]', '2026-06-18 10:52:22.72');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupu00107dfj7ostsa6d', 'cmqjdruoo00007dfje2vfvz6p', 5, 8, 'Membina Kemakmuran Negara', '["Dasar perindustrian","Dasar pertanian","Dasar pembangunan ekonomi"]', '2026-06-18 10:52:22.722');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupv00127dfjpi1te61s', 'cmqjdruoo00007dfje2vfvz6p', 5, 9, 'Dasar Luar Malaysia', '["Prinsip dasar luar","Dasar berkecuali","ASEAN, NAM, OIC, PBB"]', '2026-06-18 10:52:22.724');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrupx00147dfjm3fyxm3u', 'cmqjdruoo00007dfje2vfvz6p', 5, 10, 'Kecemerlangan Malaysia di Persada Dunia', '["Tokoh & pencapaian","Sumbangan global","Wawasan masa depan"]', '2026-06-18 10:52:22.725');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruq100177dfjfady9mnv', 'cmqjdrupz00157dfjd7j8vlqf', 4, 1, 'Karangan', '["Karangan respons terbuka","Karangan berdasarkan bahan rangsangan"]', '2026-06-18 10:52:22.729');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruq300197dfj20izvp0g', 'cmqjdrupz00157dfjd7j8vlqf', 4, 2, 'Pemahaman', '["Petikan pemahaman","Kosa kata","Memproses maklumat"]', '2026-06-18 10:52:22.731');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruq5001b7dfjd4k8zvmn', 'cmqjdrupz00157dfjd7j8vlqf', 4, 3, 'Rumusan', '["Isi tersurat","Isi tersirat"]', '2026-06-18 10:52:22.733');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruq7001d7dfj7tpeapic', 'cmqjdrupz00157dfjd7j8vlqf', 4, 4, 'Tatabahasa', '["Morfologi (bentuk kata)","Sintaksis (frasa & ayat)"]', '2026-06-18 10:52:22.735');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruq8001f7dfjjptds56d', 'cmqjdrupz00157dfjd7j8vlqf', 4, 5, 'KOMSAS Tingkatan 4', '["Antologi Jaket Kulit Kijang dari Istanbul","Novel Leftenan Adnan Wira Bangsa"]', '2026-06-18 10:52:22.737');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqa001h7dfj9m0snil1', 'cmqjdrupz00157dfjd7j8vlqf', 5, 1, 'Karangan', '["Karangan respons terbuka","Karangan berdasarkan bahan rangsangan"]', '2026-06-18 10:52:22.738');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqc001j7dfjsky56hz8', 'cmqjdrupz00157dfjd7j8vlqf', 5, 2, 'Pemahaman & Rumusan', '["Pemahaman petikan","Rumusan"]', '2026-06-18 10:52:22.74');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqd001l7dfjjhen03it', 'cmqjdrupz00157dfjd7j8vlqf', 5, 3, 'Tatabahasa', '["Golongan kata","Ayat","Laras bahasa"]', '2026-06-18 10:52:22.742');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqf001n7dfjh5p6iqla', 'cmqjdrupz00157dfjd7j8vlqf', 5, 4, 'KOMSAS Tingkatan 5', '["Antologi Sejadah Rindu","Novel Silir Daksina"]', '2026-06-18 10:52:22.744');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqj001q7dfj6u68xswh', 'cmqjdruqh001o7dfjrcz8y1v9', 4, 1, 'Reading', '["Skimming & scanning","Inference","People and Culture"]', '2026-06-18 10:52:22.747');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruql001s7dfjmw1zo9pp', 'cmqjdruqh001o7dfjrcz8y1v9', 4, 2, 'Writing', '["Emails & messages","Reviews","Short essays"]', '2026-06-18 10:52:22.749');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqm001u7dfj7sboge3d', 'cmqjdruqh001o7dfjrcz8y1v9', 4, 3, 'Speaking & Listening', '["Presentations","Discussions","Listening for gist"]', '2026-06-18 10:52:22.751');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqo001w7dfj7e4hsf6c', 'cmqjdruqh001o7dfjrcz8y1v9', 4, 4, 'Grammar in Use', '["Tenses","Subject-verb agreement","Connectors"]', '2026-06-18 10:52:22.753');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqq001y7dfj1313yqu0', 'cmqjdruqh001o7dfjrcz8y1v9', 4, 5, 'Literature in Action', '["Poems","Short stories","Drama"]', '2026-06-18 10:52:22.754');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqr00207dfjb3abvssj', 'cmqjdruqh001o7dfjrcz8y1v9', 5, 1, 'Reading', '["Extended texts","Critical reading","Science and Technology"]', '2026-06-18 10:52:22.756');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqu00227dfjs3pka310', 'cmqjdruqh001o7dfjrcz8y1v9', 5, 2, 'Writing', '["Reports","Argumentative essays","Formal letters"]', '2026-06-18 10:52:22.758');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqw00247dfjge9ltg0s', 'cmqjdruqh001o7dfjrcz8y1v9', 5, 3, 'Speaking & Listening', '["Debates","Interviews","Note-taking"]', '2026-06-18 10:52:22.76');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruqx00267dfj9ipww9ub', 'cmqjdruqh001o7dfjrcz8y1v9', 5, 4, 'Grammar in Use', '["Passive voice","Conditionals","Reported speech"]', '2026-06-18 10:52:22.762');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrur000287dfjpb0qea1u', 'cmqjdruqh001o7dfjrcz8y1v9', 5, 5, 'Literature in Action', '["Novel","Poems","Drama"]', '2026-06-18 10:52:22.764');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrur3002b7dfj00gqz5xs', 'cmqjdrur100297dfjgo81hkdn', 4, 1, 'Fungsi dan Persamaan Kuadratik dalam Satu Pemboleh Ubah', '["Fungsi kuadratik","Punca persamaan","Graf"]', '2026-06-18 10:52:22.767');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrur5002d7dfjhw9v3csz', 'cmqjdrur100297dfjgo81hkdn', 4, 2, 'Asas Nombor', '["Nilai tempat","Penukaran asas","Operasi asas n"]', '2026-06-18 10:52:22.769');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrur7002f7dfjkihzlbgh', 'cmqjdrur100297dfjgo81hkdn', 4, 3, 'Penaakulan Logik', '["Pernyataan","Pengkuantiti & negasi","Hujah deduktif/induktif"]', '2026-06-18 10:52:22.771');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrur8002h7dfj6wpi5816', 'cmqjdrur100297dfjgo81hkdn', 4, 4, 'Operasi Set', '["Persilangan","Kesatuan","Pelengkap set"]', '2026-06-18 10:52:22.773');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrura002j7dfj7mfg0jk5', 'cmqjdrur100297dfjgo81hkdn', 4, 5, 'Rangkaian dalam Teori Graf', '["Bucu & tepi","Graf berpemberat","Aplikasi rangkaian"]', '2026-06-18 10:52:22.774');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurc002l7dfjy4h0v03j', 'cmqjdrur100297dfjgo81hkdn', 4, 6, 'Ketaksamaan Linear dalam Dua Pemboleh Ubah', '["Ketaksamaan linear","Sistem ketaksamaan","Rantau"]', '2026-06-18 10:52:22.776');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurd002n7dfjnhyqkg4c', 'cmqjdrur100297dfjgo81hkdn', 4, 7, 'Graf Gerakan', '["Graf jarak-masa","Graf laju-masa","Tafsiran graf"]', '2026-06-18 10:52:22.778');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurf002p7dfjfksor5ij', 'cmqjdrur100297dfjgo81hkdn', 4, 8, 'Sukatan Serakan Data Tak Terkumpul', '["Julat & julat antara kuartil","Varians","Sisihan piawai"]', '2026-06-18 10:52:22.779');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruri002r7dfjzqv5ryx6', 'cmqjdrur100297dfjgo81hkdn', 4, 9, 'Kebarangkalian Peristiwa Bergabung', '["Peristiwa saling eksklusif","Hukum tambah","Hukum darab"]', '2026-06-18 10:52:22.782');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurj002t7dfjndi35s5s', 'cmqjdrur100297dfjgo81hkdn', 4, 10, 'Matematik Pengguna: Pengurusan Kewangan', '["Belanjawan","Aliran tunai","Simpanan & pelaburan"]', '2026-06-18 10:52:22.784');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurl002v7dfjb0ky17vv', 'cmqjdrur100297dfjgo81hkdn', 5, 1, 'Ubahan', '["Ubahan langsung","Ubahan songsang","Ubahan tercantum"]', '2026-06-18 10:52:22.785');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurn002x7dfj1ewbyk45', 'cmqjdrur100297dfjgo81hkdn', 5, 2, 'Matriks', '["Operasi matriks","Pendaraban matriks","Matriks songsang"]', '2026-06-18 10:52:22.787');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruro002z7dfjhf31ef8r', 'cmqjdrur100297dfjgo81hkdn', 5, 3, 'Matematik Pengguna: Insurans', '["Konsep risiko","Insurans nyawa & am","Premium"]', '2026-06-18 10:52:22.789');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurq00317dfjsh14naow', 'cmqjdrur100297dfjgo81hkdn', 5, 4, 'Matematik Pengguna: Percukaian', '["Cukai pendapatan","Cukai jualan & perkhidmatan","Pelepasan cukai"]', '2026-06-18 10:52:22.79');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurr00337dfjc0kks117', 'cmqjdrur100297dfjgo81hkdn', 5, 5, 'Kekongruenan, Pembesaran dan Gabungan Transformasi', '["Kekongruenan","Pembesaran","Gabungan transformasi"]', '2026-06-18 10:52:22.792');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurt00357dfjhyeg90rx', 'cmqjdrur100297dfjgo81hkdn', 5, 6, 'Nisbah dan Graf Fungsi Trigonometri', '["Nisbah trigonometri","Sudut rujuk","Graf sin, kos, tan"]', '2026-06-18 10:52:22.793');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurv00377dfjy2tc4yip', 'cmqjdrur100297dfjgo81hkdn', 5, 7, 'Sukatan Serakan Data Terkumpul', '["Jadual kekerapan","Histogram & ogif","Varians & sisihan piawai"]', '2026-06-18 10:52:22.795');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurw00397dfjpoizs4ji', 'cmqjdrur100297dfjgo81hkdn', 5, 8, 'Pemodelan Matematik', '["Proses pemodelan","Pembentukan model","Tafsiran model"]', '2026-06-18 10:52:22.796');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrurz003c7dfjske67mz3', 'cmqjdrury003a7dfjgeyjnao3', 4, 1, 'Fungsi', '["Tatatanda fungsi","Fungsi gubahan","Fungsi songsang"]', '2026-06-18 10:52:22.8');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrus1003e7dfjvjt7vgy5', 'cmqjdrury003a7dfjgeyjnao3', 4, 2, 'Fungsi Kuadratik', '["Persamaan & ketaksamaan kuadratik","Diskriminan","Graf"]', '2026-06-18 10:52:22.802');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrus3003g7dfj4cpstuah', 'cmqjdrury003a7dfjgeyjnao3', 4, 3, 'Sistem Persamaan', '["Persamaan linear tiga pemboleh ubah","Persamaan serentak"]', '2026-06-18 10:52:22.803');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrus6003i7dfj5figu1lb', 'cmqjdrury003a7dfjgeyjnao3', 4, 4, 'Indeks, Surd dan Logaritma', '["Hukum indeks","Hukum surd","Hukum logaritma"]', '2026-06-18 10:52:22.806');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrus7003k7dfjtsbk76vc', 'cmqjdrury003a7dfjgeyjnao3', 4, 5, 'Janjang', '["Janjang aritmetik","Janjang geometri","Hasil tambah hingga ketakterhinggaan"]', '2026-06-18 10:52:22.808');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrus9003m7dfjhs7gqu5z', 'cmqjdrury003a7dfjgeyjnao3', 4, 6, 'Hukum Linear', '["Garis lurus penyuaian terbaik","Bentuk tak linear ke linear"]', '2026-06-18 10:52:22.809');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusa003o7dfjw5bbxv1n', 'cmqjdrury003a7dfjgeyjnao3', 4, 7, 'Geometri Koordinat', '["Pembahagi tembereng garis","Luas poligon","Lokus"]', '2026-06-18 10:52:22.811');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusc003q7dfj1sf6m21d', 'cmqjdrury003a7dfjgeyjnao3', 4, 8, 'Vektor', '["Vektor & skalar","Vektor satah Cartesan","Operasi vektor"]', '2026-06-18 10:52:22.812');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruse003s7dfjofue8hjo', 'cmqjdrury003a7dfjgeyjnao3', 4, 9, 'Penyelesaian Segi Tiga', '["Petua sinus","Petua kosinus","Luas segi tiga"]', '2026-06-18 10:52:22.815');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusg003u7dfjmbzqnemg', 'cmqjdrury003a7dfjgeyjnao3', 4, 10, 'Nombor Indeks', '["Nombor indeks","Indeks gubahan"]', '2026-06-18 10:52:22.817');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusi003w7dfjc832fhzk', 'cmqjdrury003a7dfjgeyjnao3', 5, 1, 'Sukatan Membulat', '["Radian","Panjang lengkok","Luas sektor"]', '2026-06-18 10:52:22.818');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusk003y7dfjio12iep8', 'cmqjdrury003a7dfjgeyjnao3', 5, 2, 'Pembezaan', '["Terbitan pertama","Terbitan kedua","Kadar perubahan & maksimum-minimum"]', '2026-06-18 10:52:22.82');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusl00407dfj6pmaoo07', 'cmqjdrury003a7dfjgeyjnao3', 5, 3, 'Pengamiran', '["Kamiran tak tentu","Kamiran tentu","Luas & isi padu kisaran"]', '2026-06-18 10:52:22.822');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusn00427dfjoqxk4k69', 'cmqjdrury003a7dfjgeyjnao3', 5, 4, 'Pilih Atur dan Gabungan', '["Prinsip pendaraban","Permutasi (nPr)","Kombinasi (nCr)"]', '2026-06-18 10:52:22.823');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusp00447dfjpko3kn25', 'cmqjdrury003a7dfjgeyjnao3', 5, 5, 'Taburan Kebarangkalian', '["Pemboleh ubah rawak","Taburan binomial","Taburan normal"]', '2026-06-18 10:52:22.825');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusq00467dfj20eq4w58', 'cmqjdrury003a7dfjgeyjnao3', 5, 6, 'Fungsi Trigonometri', '["Fungsi sebarang sudut","Identiti trigonometri","Rumus sudut majmuk"]', '2026-06-18 10:52:22.827');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrust00487dfjf21siopr', 'cmqjdrury003a7dfjgeyjnao3', 5, 7, 'Pengaturcaraan Linear', '["Model ketaksamaan linear","Rantau","Nilai optimum"]', '2026-06-18 10:52:22.829');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusv004a7dfj8sp1rwzm', 'cmqjdrury003a7dfjgeyjnao3', 5, 8, 'Kinematik Gerakan Linear', '["Sesaran","Halaju","Pecutan"]', '2026-06-18 10:52:22.831');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrusy004d7dfjlm4ery10', 'cmqjdrusw004b7dfj5zh6cgwt', 4, 1, 'Pengukuran', '["Kuantiti fizik & unit","Ralat & ketidakpastian","Ketepatan & kejituan"]', '2026-06-18 10:52:22.834');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrut0004f7dfjkjiylip7', 'cmqjdrusw004b7dfj5zh6cgwt', 4, 2, 'Daya dan Gerakan I', '["Gerakan linear","Hukum Newton & momentum","Daya geseran"]', '2026-06-18 10:52:22.836');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrut1004h7dfjsskorj1g', 'cmqjdrusw004b7dfj5zh6cgwt', 4, 3, 'Kegravitian', '["Hukum kegravitian Newton","Pecutan graviti","Satelit & orbit"]', '2026-06-18 10:52:22.838');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrut3004j7dfjg2rd6bi3', 'cmqjdrusw004b7dfj5zh6cgwt', 4, 4, 'Haba', '["Keseimbangan terma","Muatan haba tentu","Haba pendam tentu"]', '2026-06-18 10:52:22.84');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrut5004l7dfjvsxrtt4b', 'cmqjdrusw004b7dfj5zh6cgwt', 4, 5, 'Gelombang', '["Gelombang melintang & membujur","Pantulan & pembiasan","Gelombang elektromagnet"]', '2026-06-18 10:52:22.841');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrut7004n7dfj7ny1awr1', 'cmqjdrusw004b7dfj5zh6cgwt', 4, 6, 'Cahaya dan Optik', '["Pembiasan cahaya","Pantulan dalam penuh","Kanta nipis & alat optik"]', '2026-06-18 10:52:22.843');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrut8004p7dfjv9bdq0pl', 'cmqjdrusw004b7dfj5zh6cgwt', 5, 1, 'Daya dan Gerakan II', '["Gerakan dua matra","Hentaman & keanjalan","Gerakan projektil"]', '2026-06-18 10:52:22.845');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruta004r7dfjqhxtomlk', 'cmqjdrusw004b7dfj5zh6cgwt', 5, 2, 'Tekanan', '["Tekanan cecair & atmosfera","Prinsip Pascal","Prinsip Archimedes & Bernoulli"]', '2026-06-18 10:52:22.846');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutc004t7dfjtlutve4a', 'cmqjdrusw004b7dfj5zh6cgwt', 5, 3, 'Keelektrikan', '["Hukum Ohm","Tenaga & kuasa elektrik","D.g.e. & rintangan dalam"]', '2026-06-18 10:52:22.848');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrute004v7dfj0wv5moqi', 'cmqjdrusw004b7dfj5zh6cgwt', 5, 4, 'Keelektromagnetan', '["Daya pada konduktor","Aruhan elektromagnet","Transformer"]', '2026-06-18 10:52:22.85');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutg004x7dfjtjsba9ub', 'cmqjdrusw004b7dfj5zh6cgwt', 5, 5, 'Elektronik', '["Sinar katod (osiloskop)","Diod & rektifikasi","Transistor"]', '2026-06-18 10:52:22.852');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruti004z7dfjxxadyp68', 'cmqjdrusw004b7dfj5zh6cgwt', 5, 6, 'Fizik Nuklear', '["Kereputan radioaktif","Tenaga nuklear (E=mc²)","Pembelahan & pelakuran"]', '2026-06-18 10:52:22.854');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutj00517dfjk27qi8r5', 'cmqjdrusw004b7dfj5zh6cgwt', 5, 7, 'Fizik Kuantum', '["Zarah gelombang","Kesan fotoelektrik","Aplikasi fotoelektrik"]', '2026-06-18 10:52:22.856');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutn00547dfjc55bjmct', 'cmqjdrutl00527dfjapskw877', 4, 1, 'Pengenalan kepada Kimia', '["Bidang & kerjaya kimia","Kaedah saintifik","Pengurusan bahan kimia"]', '2026-06-18 10:52:22.859');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruto00567dfjfbopi7ac', 'cmqjdrutl00527dfjapskw877', 4, 2, 'Jirim dan Struktur Atom', '["Teori kinetik jirim","Model atom","Isotop"]', '2026-06-18 10:52:22.861');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutq00587dfjrh64l86b', 'cmqjdrutl00527dfjapskw877', 4, 3, 'Konsep Mol, Formula dan Persamaan Kimia', '["Jisim atom relatif","Konsep mol","Formula empirik & molekul"]', '2026-06-18 10:52:22.862');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruts005a7dfjkeifdxa3', 'cmqjdrutl00527dfjapskw877', 4, 4, 'Jadual Berkala Unsur', '["Jadual berkala moden","Unsur Kumpulan 1, 17, 18","Unsur peralihan"]', '2026-06-18 10:52:22.864');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutt005c7dfjtcgqf2as', 'cmqjdrutl00527dfjapskw877', 4, 5, 'Ikatan Kimia', '["Ikatan ion","Ikatan kovalen","Sifat sebatian"]', '2026-06-18 10:52:22.866');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutv005e7dfj4rkiqrjt', 'cmqjdrutl00527dfjapskw877', 4, 6, 'Asid, Bes dan Garam', '["pH","Peneutralan","Penyediaan garam"]', '2026-06-18 10:52:22.868');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutx005g7dfjvxnpt2xb', 'cmqjdrutl00527dfjapskw877', 4, 7, 'Kadar Tindak Balas', '["Faktor mempengaruhi kadar","Mangkin","Teori perlanggaran"]', '2026-06-18 10:52:22.87');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrutz005i7dfju7p4n7xx', 'cmqjdrutl00527dfjapskw877', 4, 8, 'Bahan Buatan dalam Industri', '["Aloi","Kaca & seramik","Bahan komposit"]', '2026-06-18 10:52:22.871');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruu1005k7dfjgg3uv9il', 'cmqjdrutl00527dfjapskw877', 5, 1, 'Keseimbangan Redoks', '["Pengoksidaan & penurunan","Sel kimia & elektrolisis","Pengaratan"]', '2026-06-18 10:52:22.873');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruu2005m7dfjwr5z1xvc', 'cmqjdrutl00527dfjapskw877', 5, 2, 'Sebatian Karbon', '["Hidrokarbon (alkana, alkena)","Alkohol & asid karboksilik","Ester & lemak"]', '2026-06-18 10:52:22.875');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruu5005o7dfjhvs38lfw', 'cmqjdrutl00527dfjapskw877', 5, 3, 'Termokimia', '["Tindak balas eksotermik & endotermik","Haba peneutralan","Haba pembakaran"]', '2026-06-18 10:52:22.877');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruu7005q7dfjawueey89', 'cmqjdrutl00527dfjapskw877', 5, 4, 'Polimer', '["Pempolimeran","Getah asli","Getah sintetik"]', '2026-06-18 10:52:22.879');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruu8005s7dfj83iky05f', 'cmqjdrutl00527dfjapskw877', 5, 5, 'Kimia Konsumer dan Industri', '["Minyak & lemak","Sabun & detergen","Bahan tambah makanan"]', '2026-06-18 10:52:22.881');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruuc005v7dfjewrv84d8', 'cmqjdruua005t7dfj9q6x1q3q', 4, 1, 'Pengenalan kepada Biologi dan Peraturan Makmal', '["Bidang & kerjaya biologi","Keselamatan makmal","Pengendalian radas"]', '2026-06-18 10:52:22.884');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruud005x7dfjvbsnknkq', 'cmqjdruua005t7dfj9q6x1q3q', 4, 2, 'Biologi Sel dan Organisasi Sel', '["Struktur & fungsi sel","Organisasi sel","Sel khusus"]', '2026-06-18 10:52:22.886');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruuf005z7dfjgd7m8cks', 'cmqjdruua005t7dfj9q6x1q3q', 4, 3, 'Pergerakan Bahan Merentas Membran Plasma', '["Resapan","Osmosis","Pengangkutan aktif"]', '2026-06-18 10:52:22.887');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruuh00617dfj2lb7jovb', 'cmqjdruua005t7dfj9q6x1q3q', 4, 4, 'Komposisi Kimia dalam Sel', '["Karbohidrat & protein","Lipid","Asid nukleik"]', '2026-06-18 10:52:22.889');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruui00637dfjqig2bm5z', 'cmqjdruua005t7dfj9q6x1q3q', 4, 5, 'Metabolisme dan Enzim', '["Anabolisme & katabolisme","Tindakan enzim","Faktor mempengaruhi enzim"]', '2026-06-18 10:52:22.891');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruuk00657dfj8riihwa0', 'cmqjdruua005t7dfj9q6x1q3q', 4, 6, 'Pembahagian Sel', '["Kitaran sel & mitosis","Meiosis","Kepentingan pembahagian sel"]', '2026-06-18 10:52:22.892');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruum00677dfj00dcg9lv', 'cmqjdruua005t7dfj9q6x1q3q', 4, 7, 'Respirasi Sel', '["Respirasi aerob","Respirasi anaerob","Tenaga & ATP"]', '2026-06-18 10:52:22.894');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruun00697dfj1ntvhr80', 'cmqjdruua005t7dfj9q6x1q3q', 5, 1, 'Organisasi Tisu Tumbuhan dan Pertumbuhan', '["Meristem","Tisu tumbuhan","Pertumbuhan primer & sekunder"]', '2026-06-18 10:52:22.896');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruup006b7dfj3e9piqom', 'cmqjdruua005t7dfj9q6x1q3q', 5, 2, 'Struktur dan Fungsi Daun', '["Struktur daun","Fotosintesis","Faktor mempengaruhi fotosintesis"]', '2026-06-18 10:52:22.897');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruus006d7dfjrwsgjqdr', 'cmqjdruua005t7dfj9q6x1q3q', 5, 3, 'Nutrisi dalam Tumbuhan', '["Nutrien mineral","Pengambilan nutrien","Kepentingan nutrien"]', '2026-06-18 10:52:22.9');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruut006f7dfjzkwfyd5u', 'cmqjdruua005t7dfj9q6x1q3q', 5, 4, 'Pengangkutan dalam Tumbuhan', '["Xilem & transpirasi","Floem & translokasi"]', '2026-06-18 10:52:22.902');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruuv006h7dfjzikimomy', 'cmqjdruua005t7dfj9q6x1q3q', 5, 5, 'Gerak Balas dalam Tumbuhan', '["Tropisme","Hormon tumbuhan (auksin)","Aplikasi hormon"]', '2026-06-18 10:52:22.903');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruux006j7dfj9s0rzu4v', 'cmqjdruua005t7dfj9q6x1q3q', 5, 6, 'Pembiakan Seks dalam Tumbuhan Berbunga', '["Struktur bunga","Pendebungaan & persenyawaan","Perkembangan biji & buah"]', '2026-06-18 10:52:22.905');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruuz006l7dfj6nl9uidg', 'cmqjdruua005t7dfj9q6x1q3q', 5, 7, 'Penyesuaian Tumbuhan pada Habitat', '["Hidrofit","Xerofit","Halofit & mesofit"]', '2026-06-18 10:52:22.907');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruv0006n7dfjbenak7ep', 'cmqjdruua005t7dfj9q6x1q3q', 5, 8, 'Biodiversiti', '["Kepelbagaian hidupan","Pengelasan organisma","Kepentingan biodiversiti"]', '2026-06-18 10:52:22.909');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruv2006p7dfjtgrgxxb2', 'cmqjdruua005t7dfj9q6x1q3q', 5, 9, 'Ekosistem', '["Komponen ekosistem","Aliran tenaga & siratan makanan","Kitar nutrien"]', '2026-06-18 10:52:22.911');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruv4006r7dfjyl42jqsf', 'cmqjdruua005t7dfj9q6x1q3q', 5, 10, 'Kelestarian Alam Sekitar', '["Pencemaran","Kesan aktiviti manusia","Pemuliharaan & pemeliharaan"]', '2026-06-18 10:52:22.912');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruv6006t7dfjnkqr8eqs', 'cmqjdruua005t7dfj9q6x1q3q', 5, 11, 'Pewarisan', '["Hukum Mendel","Kacukan monohibrid & dihibrid","Penyakit genetik"]', '2026-06-18 10:52:22.914');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruv7006v7dfjj43uog4i', 'cmqjdruua005t7dfj9q6x1q3q', 5, 12, 'Variasi', '["Variasi selanjar & tak selanjar","Faktor genetik & persekitaran","Mutasi"]', '2026-06-18 10:52:22.915');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruv9006x7dfjmu0n0tit', 'cmqjdruua005t7dfj9q6x1q3q', 5, 13, 'Kejuruteraan Genetik dan Bioteknologi', '["DNA rekombinan","Aplikasi bioteknologi","Implikasi etika"]', '2026-06-18 10:52:22.917');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvc00707dfjijtmr9bg', 'cmqjdruva006y7dfjbogi4oil', 4, 1, 'Al-Quran (Tilawah)', '["Surah al-An''am & al-Kahfi","Hukum tajwid","Larangan rasuah"]', '2026-06-18 10:52:22.92');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruve00727dfjqgeywjtb', 'cmqjdruva006y7dfjbogi4oil', 4, 2, 'Hadis', '["Hindari dosa besar","Kemuliaan berdikari"]', '2026-06-18 10:52:22.923');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvg00747dfjuclumit1', 'cmqjdruva006y7dfjbogi4oil', 4, 3, 'Akidah', '["Al-Asma'' al-Husna","Perkara membatalkan iman","Hindari ajaran sesat"]', '2026-06-18 10:52:22.924');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvi00767dfjnqmmhe7s', 'cmqjdruva006y7dfjbogi4oil', 4, 4, 'Ibadah (Fiqah)', '["Haji & umrah","Sembelihan, korban & akikah","Muamalat Islam"]', '2026-06-18 10:52:22.926');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvj00787dfjkndqqqdc', 'cmqjdruva006y7dfjbogi4oil', 4, 5, 'Sirah dan Tamadun Islam', '["Khulafa ar-Rasyidin","Kerajaan Umaiyah & Abbasiyah","Tokoh empat mazhab"]', '2026-06-18 10:52:22.928');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvl007a7dfjkjknbx8r', 'cmqjdruva006y7dfjbogi4oil', 4, 6, 'Akhlak Islamiah', '["Benar & jauhi munafik","Khauf & raja''","Wasatiah"]', '2026-06-18 10:52:22.93');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvn007c7dfjl24f4wgc', 'cmqjdruva006y7dfjbogi4oil', 5, 1, 'Al-Quran (Tilawah)', '["Surah at-Taubah & al-Hasyr","Tajwid: Ra, wakaf & ibtida''","Ciri mukmin berjaya"]', '2026-06-18 10:52:22.931');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvo007e7dfjdojhml5i', 'cmqjdruva006y7dfjbogi4oil', 5, 2, 'Hadis', '["Setiap orang pemimpin","Tujuh golongan dapat naungan Allah"]', '2026-06-18 10:52:22.933');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvq007g7dfj144y67rr', 'cmqjdruva006y7dfjbogi4oil', 5, 3, 'Akidah', '["Allah Maha Mengawasi","Akidah Ahli Sunnah Waljamaah"]', '2026-06-18 10:52:22.934');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvs007i7dfj5za1h8nu', 'cmqjdruva006y7dfjbogi4oil', 5, 4, 'Ibadah (Fiqah)', '["Perkahwinan & isu-isunya","Pengurusan harta & faraid","Jenayah dalam Islam"]', '2026-06-18 10:52:22.936');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvt007k7dfjxp52h5zn', 'cmqjdruva006y7dfjbogi4oil', 5, 5, 'Sirah dan Tamadun Islam', '["Kerajaan Uthmaniyah","Keunggulan tokoh Islam"]', '2026-06-18 10:52:22.938');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvv007m7dfj1e52rore', 'cmqjdruva006y7dfjbogi4oil', 5, 6, 'Akhlak Islamiah', '["Tawaduk","Istiqamah & mujahadah","Sifat mazmumah"]', '2026-06-18 10:52:22.939');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruvy007p7dfjp4jhlaiz', 'cmqjdruvw007n7dfj03ndl73f', 4, 1, 'Insan Bermoral (Bidang 5)', '["Norma masyarakat","Peribadi mulia","Keadilan dalam membuat keputusan","Etika penggunaan ICT"]', '2026-06-18 10:52:22.942');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruw1007r7dfj1olurqvl', 'cmqjdruvw007n7dfj03ndl73f', 4, 2, 'Jati Diri Moral (Bidang 6)', '["Integriti & jati diri","Keluarga berintegriti","Perikemanusiaan"]', '2026-06-18 10:52:22.945');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruw2007t7dfjv5k5uj0o', 'cmqjdruvw007n7dfj03ndl73f', 4, 3, 'Moral dan Kenegaraan (Bidang 7)', '["Hak & tanggungjawab warganegara","Perpaduan","Keunikan rakyat Malaysia","Kedaulatan negara"]', '2026-06-18 10:52:22.947');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruw4007v7dfjwx7tlbza', 'cmqjdruvw007n7dfj03ndl73f', 5, 1, 'Insan Bermoral (Bidang 5)', '["Norma masyarakat global","Akauntabiliti","Jati diri di mata dunia","Kerohanian"]', '2026-06-18 10:52:22.949');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruw6007x7dfjv65uhhlr', 'cmqjdruvw007n7dfj03ndl73f', 5, 2, 'Jati Diri Moral (Bidang 6)', '["Integriti organisasi","Keluarga","Pembangunan negara berintegriti"]', '2026-06-18 10:52:22.95');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruw8007z7dfjz645rp3o', 'cmqjdruvw007n7dfj03ndl73f', 5, 3, 'Moral dan Kenegaraan (Bidang 7)', '["Penglibatan komuniti","Kerjasama masyarakat global","Pengurusan kewangan beretika","Hubungan antarabangsa"]', '2026-06-18 10:52:22.952');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwb00827dfj0p6x4p9o', 'cmqjdruwa00807dfjqlk706mv', 4, 1, 'Pengenalan kepada Ekonomi', '["Masalah asas ekonomi","Kos lepas & KKP","Sistem ekonomi"]', '2026-06-18 10:52:22.956');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwd00847dfj8rjoi69o', 'cmqjdruwa00807dfjqlk706mv', 4, 2, 'Pasaran', '["Permintaan & penawaran","Keseimbangan pasaran","Keanjalan"]', '2026-06-18 10:52:22.957');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwf00867dfjwwfll9n1', 'cmqjdruwa00807dfjqlk706mv', 4, 3, 'Wang, Bank dan Pendapatan Individu', '["Fungsi wang","Sistem perbankan","Pendapatan individu"]', '2026-06-18 10:52:22.959');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwk00887dfjggoxna7b', 'cmqjdruwa00807dfjqlk706mv', 4, 4, 'Pengeluaran', '["Faktor pengeluaran","Jenis pasaran","Kos & hasil"]', '2026-06-18 10:52:22.965');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwn008a7dfj5txdd3a0', 'cmqjdruwa00807dfjqlk706mv', 5, 1, 'Ekonomi dan Kerajaan', '["Dasar fiskal & belanjawan","Dasar kewangan","Guna tenaga & inflasi"]', '2026-06-18 10:52:22.967');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwo008c7dfjqppw14gt', 'cmqjdruwa00807dfjqlk706mv', 5, 2, 'Malaysia dan Ekonomi Global', '["Globalisasi & FDI","Perdagangan antarabangsa","Imbangan pembayaran & kadar pertukaran"]', '2026-06-18 10:52:22.969');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruws008f7dfjitmoc5tj', 'cmqjdruwq008d7dfj8fh00ni1', 4, 1, 'Pengenalan kepada Perakaunan', '["Perakaunan vs simpan kira","Profesion perakaunan","Prinsip & andaian"]', '2026-06-18 10:52:22.972');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwu008h7dfjxaqo4qx3', 'cmqjdruwq008d7dfj8fh00ni1', 4, 2, 'Klasifikasi Akaun dan Persamaan Perakaunan', '["Aset, liabiliti, ekuiti","Persamaan perakaunan","Kesan urus niaga"]', '2026-06-18 10:52:22.975');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruww008j7dfjiogcei7l', 'cmqjdruwq008d7dfj8fh00ni1', 4, 3, 'Dokumen Perakaunan sebagai Sumber Maklumat', '["Invois & nota debit/kredit","Resit & baucar","Penggunaan dokumen"]', '2026-06-18 10:52:22.976');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwy008l7dfj6octk2s1', 'cmqjdruwq008d7dfj8fh00ni1', 4, 4, 'Buku Catatan Pertama', '["Jurnal am & khas","Buku tunai"]', '2026-06-18 10:52:22.978');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruwz008n7dfjck0480be', 'cmqjdruwq008d7dfj8fh00ni1', 4, 5, 'Lejar', '["Akaun T","Pengeposan","Pengimbangan akaun"]', '2026-06-18 10:52:22.98');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrux1008p7dfjv48jkrw7', 'cmqjdruwq008d7dfj8fh00ni1', 4, 6, 'Imbangan Duga', '["Penyediaan imbangan duga","Fungsi","Kesilapan tidak menjejaskan"]', '2026-06-18 10:52:22.981');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrux2008r7dfjkb3fz1pi', 'cmqjdruwq008d7dfj8fh00ni1', 4, 7, 'Penyata Kewangan Milikan Tunggal tanpa Pelarasan', '["Penyata pendapatan","Penyata kedudukan kewangan"]', '2026-06-18 10:52:22.983');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrux4008t7dfjirdfpghm', 'cmqjdruwq008d7dfj8fh00ni1', 4, 8, 'Pelarasan dan Penyata Kewangan Milikan Tunggal', '["Belanja/hasil terakru & terdahulu","Susut nilai","Hutang lapuk & peruntukan"]', '2026-06-18 10:52:22.984');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrux5008v7dfj9510zkhs', 'cmqjdruwq008d7dfj8fh00ni1', 4, 9, 'Pembetulan Kesilapan', '["Jenis kesilapan","Jurnal pembetulan","Akaun penggantungan"]', '2026-06-18 10:52:22.986');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrux7008x7dfjap9ltf82', 'cmqjdruwq008d7dfj8fh00ni1', 5, 1, 'Analisis dan Tafsiran Penyata Kewangan', '["Nisbah keberuntungan","Nisbah kecairan","Tafsiran prestasi"]', '2026-06-18 10:52:22.987');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdrux8008z7dfjytd4nwkw', 'cmqjdruwq008d7dfj8fh00ni1', 5, 2, 'Rekod Tak Lengkap', '["Untung/rugi daripada perubahan ekuiti","Kaedah analisis","Penyata kewangan"]', '2026-06-18 10:52:22.989');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruxa00917dfj5aztfm11', 'cmqjdruwq008d7dfj8fh00ni1', 5, 3, 'Perakaunan untuk Kawalan Dalaman', '["Kawalan tunai","Penyata penyesuaian bank","Belanjawan tunai"]', '2026-06-18 10:52:22.99');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruxc00937dfj0pa2w3px', 'cmqjdruwq008d7dfj8fh00ni1', 5, 4, 'Perakaunan untuk Perkongsian', '["Akaun modal & semasa","Perjanjian perkongsian","Agihan untung rugi"]', '2026-06-18 10:52:22.993');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruxe00957dfjz4kxytbj', 'cmqjdruwq008d7dfj8fh00ni1', 5, 5, 'Perakaunan untuk Syarikat Berhad menurut Syer', '["Jenis & terbitan syer","Debentur","Penyata kewangan syarikat"]', '2026-06-18 10:52:22.994');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruxf00977dfjehctipcn', 'cmqjdruwq008d7dfj8fh00ni1', 5, 6, 'Perakaunan untuk Kelab dan Persatuan', '["Akaun penerimaan & pembayaran","Akaun yuran ahli","Akaun pendapatan & perbelanjaan"]', '2026-06-18 10:52:22.996');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqjdruxh00997dfjgee2u6dh', 'cmqjdruwq008d7dfj8fh00ni1', 5, 7, 'Perakaunan Kos', '["Kos pengeluaran","Penyata kos pengeluaran","Klasifikasi kos"]', '2026-06-18 10:52:22.997');


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxj009b7dfjhep5wrkc', 'cmqjdruoo00007dfje2vfvz6p', 'cmqjdruot00027dfjwivr25hz', NULL, 1, 'mcq', '1', 'Antara berikut, yang manakah merupakan ciri utama sebuah negara bangsa?', '[{"key":"A","text":"Mempunyai wilayah dan sempadan yang jelas"},{"key":"B","text":"Tidak memerlukan kerajaan"},{"key":"C","text":"Tiada perlembagaan"},{"key":"D","text":"Rakyat daripada pelbagai negara"}]', 'A', NULL, NULL, 1, false, 'Ciri negara bangsa', 2025, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:22.998', '2026-06-18 10:52:22.999');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxm009d7dfj1yokh5o6', 'cmqjdruoo00007dfje2vfvz6p', 'cmqjdrup3000a7dfj8cufyzb4', NULL, 1, 'mcq', '2', 'Mengapakah orang Melayu menentang penubuhan Malayan Union?', '[{"key":"A","text":"Menghapuskan kedaulatan Raja-Raja Melayu"},{"key":"B","text":"Menambah kuasa Sultan"},{"key":"C","text":"Memperluas hak istimewa Melayu"},{"key":"D","text":"Menyatukan Tanah Melayu dengan Indonesia"}]', 'A', NULL, NULL, 1, true, 'Penentangan Melayu', 2025, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.001', '2026-06-18 10:52:23.002');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxo009f7dfj2vd9whco', 'cmqjdruoo00007dfje2vfvz6p', 'cmqjdrup9000g7dfjq17y1aw9', NULL, 2, 'structured', '1(a)', 'Nyatakan dua usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu.', '[]', 'Pakatan Murni antara kaum; Sistem Ahli; Pilihan Raya Umum 1955; Rombongan ke London 1956.', '1 markah setiap usaha (maks 2).', NULL, 2, false, 'Pakatan Murni', 2025, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.003', '2026-06-18 10:52:23.004');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxq009h7dfj5n0jb5at', 'cmqjdruoo00007dfje2vfvz6p', 'cmqjdrup9000g7dfjq17y1aw9', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Pilihan Raya 1955', 2025, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.005', '2026-06-18 10:52:23.006');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxs009j7dfjfbpoi6rm', 'cmqjdrur100297dfjgo81hkdn', 'cmqjdrur3002b7dfj00gqz5xs', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.007', '2026-06-18 10:52:23.008');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxv009l7dfjgttsqigk', 'cmqjdrur100297dfjgo81hkdn', 'cmqjdruri002r7dfjzqv5ryx6', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.01', '2026-06-18 10:52:23.011');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxw009n7dfj5i7vb1ux', 'cmqjdrury003a7dfjgeyjnao3', 'cmqjdrusk003y7dfjio12iep8', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.012', '2026-06-18 10:52:23.013');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruxy009p7dfjmg7pgloq', 'cmqjdrusw004b7dfj5zh6cgwt', 'cmqjdrut0004f7dfjkjiylip7', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.014', '2026-06-18 10:52:23.015');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruy0009r7dfjssi1jgzt', 'cmqjdrusw004b7dfj5zh6cgwt', 'cmqjdrut3004j7dfjg2rd6bi3', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.016', '2026-06-18 10:52:23.017');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruy2009t7dfjfddqxj9l', 'cmqjdrutl00527dfjapskw877', 'cmqjdrutv005e7dfj4rkiqrjt', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.018', '2026-06-18 10:52:23.018');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruy4009v7dfjaxpdk0bo', 'cmqjdrutl00527dfjapskw877', 'cmqjdrutv005e7dfj4rkiqrjt', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.019', '2026-06-18 10:52:23.02');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruy5009x7dfjwpbjk2bk', 'cmqjdruua005t7dfj9q6x1q3q', 'cmqjdruup006b7dfj3e9piqom', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.021', '2026-06-18 10:52:23.022');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruy7009z7dfjzcthcm4p', 'cmqjdruua005t7dfj9q6x1q3q', 'cmqjdruud005x7dfjvbsnknkq', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.023', '2026-06-18 10:52:23.023');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruya00a17dfjsej2qpww', 'cmqjdruqh001o7dfjrcz8y1v9', 'cmqjdruqu00227dfjs3pka310', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.025', '2026-06-18 10:52:23.026');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruyc00a37dfj8zuyvzdc', 'cmqjdrupz00157dfjd7j8vlqf', 'cmqjdruqa001h7dfj9m0snil1', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', 'approved', 0.96, false, 'Curated seed content', NULL, '2026-06-18 10:52:23.027', '2026-06-18 10:52:23.028');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruyg00a77dfj6kf2hy5e', 'cmqjdrury003a7dfjgeyjnao3', 'cmqjdrurz003c7dfjske67mz3', 'cmqjdruyd00a57dfj00jxqvhe', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', 'pending', 0.55, false, NULL, NULL, NULL, '2026-06-18 10:52:23.032');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruyi00a97dfjbqbdh9z2', 'cmqjdrury003a7dfjgeyjnao3', 'cmqjdrusn00427dfjoqxk4k69', 'cmqjdruyd00a57dfj00jxqvhe', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', 'pending', 0.68, false, NULL, NULL, NULL, '2026-06-18 10:52:23.034');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruyj00ab7dfjrit4elo1', 'cmqjdrury003a7dfjgeyjnao3', 'cmqjdrusl00407dfj6pmaoo07', 'cmqjdruyd00a57dfj00jxqvhe', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', 'pending', 0.78, false, NULL, NULL, NULL, '2026-06-18 10:52:23.036');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruyn00af7dfj52hpscf9', 'cmqjdruua005t7dfj9q6x1q3q', 'cmqjdruud005x7dfjvbsnknkq', 'cmqjdruyl00ad7dfjvm8x3tjd', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', 'pending', 0.55, false, NULL, NULL, NULL, '2026-06-18 10:52:23.04');
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, status, confidence, "autoApproved", "reviewNote", "reviewedById", "reviewedAt", "createdAt") VALUES ('cmqjdruyp00ah7dfjc2b49av1', 'cmqjdruua005t7dfj9q6x1q3q', 'cmqjdruv6006t7dfjnkqr8eqs', 'cmqjdruyl00ad7dfjvm8x3tjd', 2, 'structured', '2', 'In a monohybrid cross between two heterozygous tall pea plants (Tt × Tt), state the expected genotypic and phenotypic ratios of the offspring.', '[]', 'Genotypic ratio 1 TT : 2 Tt : 1 tt; phenotypic ratio 3 tall : 1 short.', 'Genotypic ratio (1m); phenotypic ratio (1m); correct reasoning (1m).', NULL, 3, false, NULL, 2024, 'past_paper', 'pending', 0.68, false, NULL, NULL, NULL, '2026-06-18 10:52:23.042');


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, school, age, state, whatsapp, "pdpaConsent", "consentAt", "createdAt") VALUES ('cmqjdrv1j00ap7dfjh1ozz5o5', 'Vikhash', 'vikhash@student.spm.my', 5, NULL, NULL, NULL, '+60123456789', true, '2026-06-18 10:52:23.142', '2026-06-18 10:52:23.143');
INSERT INTO public."Student" (id, name, email, form, school, age, state, whatsapp, "pdpaConsent", "consentAt", "createdAt") VALUES ('cmqjdrv5500bo7dfjomv5k399', 'Ahmad', 'ahmad@student.spm.my', 5, NULL, NULL, NULL, NULL, true, '2026-06-18 10:52:23.273', '2026-06-18 10:52:23.273');
INSERT INTO public."Student" (id, name, email, form, school, age, state, whatsapp, "pdpaConsent", "consentAt", "createdAt") VALUES ('cmqjdrv8p00cn7dfj6mxvtbxz', 'Siti Nurhaliza', 'siti@student.spm.my', 5, NULL, NULL, NULL, NULL, true, '2026-06-18 10:52:23.4', '2026-06-18 10:52:23.401');
INSERT INTO public."Student" (id, name, email, form, school, age, state, whatsapp, "pdpaConsent", "consentAt", "createdAt") VALUES ('cmqjdrvca00dq7dfj56qy9cc9', 'Kumar Raj', 'kumar@student.spm.my', 4, NULL, NULL, NULL, NULL, true, '2026-06-18 10:52:23.53', '2026-06-18 10:52:23.531');
INSERT INTO public."Student" (id, name, email, form, school, age, state, whatsapp, "pdpaConsent", "consentAt", "createdAt") VALUES ('cmqjdrvg100er7dfj6aiwc5jw', 'Mei Ling', 'meiling@student.spm.my', 5, NULL, NULL, NULL, NULL, true, '2026-06-18 10:52:23.664', '2026-06-18 10:52:23.665');


--
-- Data for Name: Attempt; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv4n00bd7dfjk1wqyxwc', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruxj009b7dfjhep5wrkc', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-10 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv4r00bf7dfj2sk5s3nx', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-12 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv4u00bh7dfj2x55x8ey', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruyc00a37dfj8zuyvzdc', 'Jawapan contoh pelajar.', 22, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-13 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv4x00bj7dfjvugez3b2', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruxw009n7dfj5i7vb1ux', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-15 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv5000bl7dfjl1pvp8f4', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruya00a17dfjsej2qpww', 'Jawapan contoh pelajar.', 13, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-16 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv8300c87dfjsi5awp36', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruxm009d7dfj1yokh5o6', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-07 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv8600ca7dfj6sz76e1g', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruy2009t7dfjfddqxj9l', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-09 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv8900cc7dfjzl40wb1s', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruxm009d7dfj1yokh5o6', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-10 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv8d00ce7dfjdmu5mazn', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruy2009t7dfjfddqxj9l', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-12 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv8g00cg7dfj7umes3b1', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruxm009d7dfj1yokh5o6', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-13 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv8i00ci7dfj0naxh2zg', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruy2009t7dfjfddqxj9l', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-15 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrv8l00ck7dfjdbpoenpg', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruxm009d7dfj1yokh5o6', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-16 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvbm00d77dfj7p3fq9se', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruxo009f7dfj2vd9whco', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-04 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvbo00d97dfj287kw04y', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruya00a17dfjsej2qpww', 'Jawapan contoh pelajar.', 26, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-06 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvbr00db7dfjz4lxmeol', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruxv009l7dfjgttsqigk', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-07 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvbt00dd7dfjutx0ac75', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruxm009d7dfj1yokh5o6', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-09 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvbw00df7dfjdhq54ma2', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruy0009r7dfjssi1jgzt', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-10 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvbz00dh7dfjj4w8dszj', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruxs009j7dfjfbpoi6rm', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-12 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvc200dj7dfjcv89po1d', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruxj009b7dfjhep5wrkc', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-13 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvc400dl7dfjs2izn0te', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-15 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvc700dn7dfjemnp5g3r', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruxq009h7dfj5n0jb5at', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-16 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvf300e47dfjj1so87fn', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-01 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvf500e67dfj3s8ewc4d', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-03 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvf900e87dfjqnu1dajk', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-04 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvfc00ea7dfj99xpfpem', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-06 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvff00ec7dfjbtswr58p', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-07 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvfi00ee7dfj0bhb38ar', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-09 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvfl00eg7dfjniih84e9', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-10 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvfo00ei7dfjfuwcsfza', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-12 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvfs00ek7dfjsqopiccv', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-13 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvfu00em7dfj44j063xs', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-15 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvfx00eo7dfjgsd0omue', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdruxy009p7dfjmg7pgloq', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-16 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrviy00f97dfjmzwit5ya', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruy2009t7dfjfddqxj9l', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-05-29 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvj200fb7dfj2k74wezs', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruxm009d7dfj1yokh5o6', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-05-31 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvj500fd7dfjvi6hb0ud', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruya00a17dfjsej2qpww', 'Jawapan contoh pelajar.', 19, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-01 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvj800ff7dfjkc3btx7s', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruy4009v7dfjaxpdk0bo', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-03 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjb00fh7dfjun5pg2t0', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruxo009f7dfj2vd9whco', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-04 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvje00fj7dfjdr9f0wtp', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruyc00a37dfj8zuyvzdc', 'Jawapan contoh pelajar.', 14, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-06 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjh00fl7dfjuo8gb0ca', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruy5009x7dfjwpbjk2bk', 'Jawapan contoh pelajar.', 5, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-07 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjj00fn7dfjy9bt241b', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruxq009h7dfj5n0jb5at', 'Jawapan contoh pelajar.', 12, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-09 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjm00fp7dfj3frn2f9y', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruxj009b7dfjhep5wrkc', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-10 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjp00fr7dfjod3bdilk', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruy7009z7dfjzcthcm4p', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-12 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjs00ft7dfjg5tf8xr1', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruy2009t7dfjfddqxj9l', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-13 22:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjv00fv7dfj0zs8y336', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruxm009d7dfj1yokh5o6', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 280, '2026-06-15 10:52:23.142');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqjdrvjy00fx7dfj3d2rr2or', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruya00a17dfjsej2qpww', 'Jawapan contoh pelajar.', 14, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 300, '2026-06-16 22:52:23.142');


--
-- Data for Name: Bookmark; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Enrollment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv3u00at7dfja66x6g1i', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruoo00007dfje2vfvz6p', 'active', '2026-06-18 10:52:23.227');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv3z00av7dfjuli9e570', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdrupz00157dfjd7j8vlqf', 'active', '2026-06-18 10:52:23.231');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv4100ax7dfjucsaw1xh', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruqh001o7dfjrcz8y1v9', 'active', '2026-06-18 10:52:23.234');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv4500az7dfjoqvi3ayg', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdrur100297dfjgo81hkdn', 'active', '2026-06-18 10:52:23.238');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv4800b17dfj7qqorx4g', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdrury003a7dfjgeyjnao3', 'active', '2026-06-18 10:52:23.24');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv4a00b37dfjzski3i7x', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdrusw004b7dfj5zh6cgwt', 'active', '2026-06-18 10:52:23.243');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv4d00b57dfjbt75z4is', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdrutl00527dfjapskw877', 'active', '2026-06-18 10:52:23.245');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv4f00b77dfjvm0186op', 'cmqjdrv1j00ap7dfjh1ozz5o5', 'cmqjdruua005t7dfj9q6x1q3q', 'active', '2026-06-18 10:52:23.247');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv7h00bs7dfjap58fazh', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruoo00007dfje2vfvz6p', 'active', '2026-06-18 10:52:23.357');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv7k00bu7dfjxinuutd0', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdrur100297dfjgo81hkdn', 'active', '2026-06-18 10:52:23.361');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv7n00bw7dfjhpla4yzw', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdrusw004b7dfj5zh6cgwt', 'active', '2026-06-18 10:52:23.364');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv7q00by7dfjduz8fdq5', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdrutl00527dfjapskw877', 'active', '2026-06-18 10:52:23.366');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv7t00c07dfj16fokcwo', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruua005t7dfj9q6x1q3q', 'active', '2026-06-18 10:52:23.369');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv7v00c27dfjhx5vxq0r', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdrupz00157dfjd7j8vlqf', 'active', '2026-06-18 10:52:23.371');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrv7y00c47dfjyagyuo7y', 'cmqjdrv5500bo7dfjomv5k399', 'cmqjdruqh001o7dfjrcz8y1v9', 'active', '2026-06-18 10:52:23.374');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvb100cr7dfjy519s1yw', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruoo00007dfje2vfvz6p', 'active', '2026-06-18 10:52:23.485');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvb300ct7dfj1c88jsgh', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdrupz00157dfjd7j8vlqf', 'active', '2026-06-18 10:52:23.488');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvb600cv7dfjrz9965fu', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdruqh001o7dfjrcz8y1v9', 'active', '2026-06-18 10:52:23.49');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvb900cx7dfjuoimzh4w', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdrur100297dfjgo81hkdn', 'active', '2026-06-18 10:52:23.493');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvbb00cz7dfjdbuyr89s', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdrury003a7dfjgeyjnao3', 'active', '2026-06-18 10:52:23.496');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvbd00d17dfjh1s8xkhg', 'cmqjdrv8p00cn7dfj6mxvtbxz', 'cmqjdrusw004b7dfj5zh6cgwt', 'active', '2026-06-18 10:52:23.498');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvep00du7dfj05jvh2oj', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdrur100297dfjgo81hkdn', 'active', '2026-06-18 10:52:23.617');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrves00dw7dfjculfihi7', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdrury003a7dfjgeyjnao3', 'active', '2026-06-18 10:52:23.62');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvev00dy7dfjgconqihm', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdrusw004b7dfj5zh6cgwt', 'active', '2026-06-18 10:52:23.623');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvex00e07dfjnukti58x', 'cmqjdrvca00dq7dfj56qy9cc9', 'cmqjdrutl00527dfjapskw877', 'active', '2026-06-18 10:52:23.626');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvif00ev7dfj2wmpib79', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruoo00007dfje2vfvz6p', 'active', '2026-06-18 10:52:23.752');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvii00ex7dfj7d23nxv9', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdrupz00157dfjd7j8vlqf', 'active', '2026-06-18 10:52:23.755');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvil00ez7dfj45zbkuxj', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruqh001o7dfjrcz8y1v9', 'active', '2026-06-18 10:52:23.757');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrvio00f17dfj1oqhdjhr', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdruua005t7dfj9q6x1q3q', 'active', '2026-06-18 10:52:23.76');
INSERT INTO public."Enrollment" (id, "studentId", "subjectId", status, "createdAt") VALUES ('cmqjdrviq00f37dfjfrw64vrp', 'cmqjdrvg100er7dfj6aiwc5jw', 'cmqjdrutl00527dfjapskw877', 'active', '2026-06-18 10:52:23.763');


--
-- Data for Name: GeneratedQuestion; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: KnowledgeDoc; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt", chapter, language, "sourceKey", "sourceUrl", "topicId") VALUES ('cmqjdruys00aj7dfji1igg3t8', 'Photosynthesis — key concepts', 'cmqjdruua005t7dfj9q6x1q3q', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-18 10:52:23.045', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt", chapter, language, "sourceKey", "sourceUrl", "topicId") VALUES ('cmqjdruyu00al7dfjqfdyih04', 'Acids, bases & salts — essentials', 'cmqjdrutl00527dfjapskw877', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-18 10:52:23.047', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt", chapter, language, "sourceKey", "sourceUrl", "topicId") VALUES ('cmqjdruyw00an7dfjqvrck42g', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqjdruoo00007dfje2vfvz6p', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-18 10:52:23.048', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: MockPaper; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: PasswordReset; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrv4i00b97dfjaprj9jb5', 'cmqjdrv1j00ap7dfjh1ozz5o5', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-13 10:52:23.142');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrv4k00bb7dfjplvi4cfy', 'cmqjdrv1j00ap7dfjh1ozz5o5', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-08 10:52:23.142');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrv8000c67dfjo2s2arw6', 'cmqjdrv5500bo7dfjomv5k399', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-08 10:52:23.142');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrvbg00d37dfj21mkdyrd', 'cmqjdrv8p00cn7dfj6mxvtbxz', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-03 10:52:23.142');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrvbj00d57dfjwo0mfywn', 'cmqjdrv8p00cn7dfj6mxvtbxz', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-06 10:52:23.142');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrvf000e27dfjn9yfalad', 'cmqjdrvca00dq7dfj56qy9cc9', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-29 10:52:23.142');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrvit00f57dfjxdbebkis', 'cmqjdrvg100er7dfj6aiwc5jw', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-05-24 10:52:23.142');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqjdrviv00f77dfjeta63sqb', 'cmqjdrvg100er7dfj6aiwc5jw', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-04 10:52:23.142');


--
-- Data for Name: PushSubscription; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ReviewItem; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqjdrv5200bn7dfjb1u5rxx8', 'cmqjdrv1j00ap7dfjh1ozz5o5', NULL, 1200, 5, '2026-06-18 10:52:23.27');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqjdrv8n00cm7dfjdgqvubab', 'cmqjdrv5500bo7dfjomv5k399', NULL, 1800, 7, '2026-06-18 10:52:23.399');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqjdrvc900dp7dfjzf1xx7j3', 'cmqjdrv8p00cn7dfj6mxvtbxz', NULL, 2400, 9, '2026-06-18 10:52:23.529');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqjdrvfz00eq7dfj1sinorvq', 'cmqjdrvca00dq7dfj56qy9cc9', NULL, 3000, 11, '2026-06-18 10:52:23.663');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqjdrvk000fz7dfjbi1uljer', 'cmqjdrvg100er7dfj6aiwc5jw', NULL, 3600, 13, '2026-06-18 10:52:23.809');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqjdrv1f00ao7dfj66adnfru', 'admin@spm.my', 'Admin Cikgu', 'admin', '9c206a08e59ea0c65d43f00d7bb4fea7:bbcb9b4eda50458221302333fefed3b9ab7d52615d580382c3f270415383c8167d22403724e7bce81e93191aa4480e923f24e2702f4e238a4e8d7d0cb94056bb', NULL, '2026-06-18 10:52:23.139');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqjdrv3r00ar7dfj2dhldzpp', 'vikhash@student.spm.my', 'Vikhash', 'student', '40bb51c02564c6e27b07a011364568a5:1da6abaab67e872286b532556023cd38787f37e5f957ec57425074fe247c22590962dfd62ff45b0b2555aeb20d446f63d484365c1c41140574aa553283784d27', 'cmqjdrv1j00ap7dfjh1ozz5o5', '2026-06-18 10:52:23.223');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqjdrv7e00bq7dfjnxyb46vt', 'ahmad@student.spm.my', 'Ahmad', 'student', '2069e7fc38f4e0c5815f420eb6222fdb:8307e49ec48c0aa248d839bab4bc3bf64b78461e57ebc99c89be03953e9fd7ddda63325b0fc19e1db4653a0119efa4c34723672af1683390c651d4f7a382956b', 'cmqjdrv5500bo7dfjomv5k399', '2026-06-18 10:52:23.355');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqjdrvay00cp7dfj7townt66', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', 'c038093197943f7bd8874fe9d223aab6:10756b577b1df44cd507472828a915260c4cf3b7a6f5346c52d909c2a4aa18b91ca6e607cdd3a9aee1f0af72253b111b306ccc349e6b0cf060500485457231cd', 'cmqjdrv8p00cn7dfj6mxvtbxz', '2026-06-18 10:52:23.482');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqjdrvel00ds7dfjema4xqup', 'kumar@student.spm.my', 'Kumar Raj', 'student', 'a9a0d866f488e96e1f4e29922c599593:c815cde5b14f69a102469442feb962869fef229f660b8fc4a39f551eacae0a150a38c4ef1b710b926608000a19e7ec77e1c8a06c609056cd1aa54c2f4b009d05', 'cmqjdrvca00dq7dfj56qy9cc9', '2026-06-18 10:52:23.613');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqjdrvid00et7dfjq59l7i60', 'meiling@student.spm.my', 'Mei Ling', 'student', '3fab2d608684718d523e59d4e5c37158:d9beea47eee2c93bf3f4a851f9e2a2b439749106fec211841f8d66184a7c8b53cc7d21e0db871adf130454a9a668f7b11754ca30c7788c68ca8a7210fe3c146a', 'cmqjdrvg100er7dfj6aiwc5jw', '2026-06-18 10:52:23.749');


--
-- Data for Name: Waitlist; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- PostgreSQL database dump complete
--


