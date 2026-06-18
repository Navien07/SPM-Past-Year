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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "reviewNote" text,
    "reviewedAt" timestamp(3) without time zone,
    "reviewedById" text,
    status text DEFAULT 'approved'::text NOT NULL,
    "autoApproved" boolean DEFAULT false NOT NULL,
    confidence double precision
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "consentAt" timestamp(3) without time zone,
    "pdpaConsent" boolean DEFAULT false NOT NULL,
    whatsapp text,
    age integer,
    school text,
    state text
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
-- Name: KnowledgeDoc_subjectId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "KnowledgeDoc_subjectId_idx" ON public."KnowledgeDoc" USING btree ("subjectId");


--
-- Name: Paper_paperType_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Paper_paperType_idx" ON public."Paper" USING btree ("paperType");


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
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj3nl6m00267ddp0dyffk9f', 'Pendidikan Islam', 'Islamic Studies', 'PI', '#0f766e', '2026-06-18 06:09:07.583');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj3nl6z002h7ddpunq1d4al', 'Pendidikan Moral', 'Moral Education', 'PM', '#9333ea', '2026-06-18 06:09:07.595');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj3nl78002q7ddpinvr1ml9', 'Ekonomi', 'Economics', 'EKO', '#ca8a04', '2026-06-18 06:09:07.604');
INSERT INTO public."Subject" (id, name, "nameEn", code, color, "createdAt") VALUES ('cmqj3nl7i002z7ddpezz8mxfo', 'Prinsip Perakaunan', 'Principles of Accounting', 'PP', '#0891b2', '2026-06-18 06:09:07.614');


--
-- Data for Name: Paper; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj1mhxl00317d000nv0e4e7', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqj1mhvu001a7d00b2ndjo2k', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 05:12:17.481', '2026-06-18 05:12:17.482');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj1mhxu00397d00cw52lic2', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqj1mhwi001z7d00gyf8hqzd', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 05:12:17.49', '2026-06-18 05:12:17.49');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj3nl8r00437ddpty8nb09k', 'Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)', 'cmqj1mhvu001a7d00b2ndjo2k', 'trial', 2025, 'Johor', 1, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 06:09:07.658', '2026-06-18 06:09:07.659');
INSERT INTO public."Paper" (id, title, "subjectId", "paperType", year, state, "paperNumber", "fileUrl", "fileName", "rawText", "markingScheme", rubric, status, "categorizedAt", "createdAt") VALUES ('cmqj3nl91004b7ddpwk57upof', 'Biology Kertas 2 — Percubaan SPM 2024 (Kedah)', 'cmqj1mhwi001z7d00gyf8hqzd', 'trial', 2024, 'Kedah', 2, NULL, NULL, 'Uploaded by admin; AI-categorized; awaiting moderation.', NULL, NULL, 'categorized', '2026-06-18 06:09:07.669', '2026-06-18 06:09:07.669');


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
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl6o00287ddparcyehhm', 'cmqj3nl6m00267ddp0dyffk9f', 4, 1, 'Tilawah Al-Quran', '["Ayat hafazan","Hukum tajwid"]', '2026-06-18 06:09:07.585');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl6s002a7ddpqaa7qux8', 'cmqj3nl6m00267ddp0dyffk9f', 4, 2, 'Akidah', '["Rukun iman","Sifat Allah"]', '2026-06-18 06:09:07.588');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl6u002c7ddp13yronvd', 'cmqj3nl6m00267ddp0dyffk9f', 4, 3, 'Ibadah', '["Solat","Zakat","Haji"]', '2026-06-18 06:09:07.59');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl6v002e7ddp6e9uxkrj', 'cmqj3nl6m00267ddp0dyffk9f', 5, 4, 'Sirah & Tamadun Islam', '["Riwayat Nabi","Kerajaan Islam"]', '2026-06-18 06:09:07.592');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl6x002g7ddpxj4v3qx4', 'cmqj3nl6m00267ddp0dyffk9f', 5, 5, 'Akhlak Islamiah', '["Adab","Nilai murni"]', '2026-06-18 06:09:07.594');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl70002j7ddpibfmyo5s', 'cmqj3nl6z002h7ddpunq1d4al', 4, 1, 'Nilai Berkaitan Diri', '["Amanah","Harga diri","Kerajinan"]', '2026-06-18 06:09:07.597');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl72002l7ddpwoi45cj2', 'cmqj3nl6z002h7ddpunq1d4al', 4, 2, 'Nilai Kekeluargaan', '["Kasih sayang","Tanggungjawab"]', '2026-06-18 06:09:07.599');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl74002n7ddp4ckjzms6', 'cmqj3nl6z002h7ddpunq1d4al', 5, 3, 'Nilai Alam Sekitar', '["Kemampanan","Peka terhadap alam"]', '2026-06-18 06:09:07.601');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl76002p7ddpw9pdhiyb', 'cmqj3nl6z002h7ddpunq1d4al', 5, 4, 'Nilai Kemasyarakatan & Negara', '["Hormat","Patriotisme","Keharmonian"]', '2026-06-18 06:09:07.602');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl79002s7ddp4x5ttesm', 'cmqj3nl78002q7ddpinvr1ml9', 4, 1, 'Pengenalan kepada Ekonomi', '["Masalah ekonomi asas","Kos lepas"]', '2026-06-18 06:09:07.606');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl7b002u7ddp7877x9cl', 'cmqj3nl78002q7ddpinvr1ml9', 4, 2, 'Permintaan & Penawaran', '["Keseimbangan pasaran","Keanjalan"]', '2026-06-18 06:09:07.608');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl7d002w7ddphgewq7gc', 'cmqj3nl78002q7ddpinvr1ml9', 5, 3, 'Wang & Institusi Kewangan', '["Fungsi wang","Bank"]', '2026-06-18 06:09:07.609');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl7g002y7ddpacgh0den', 'cmqj3nl78002q7ddpinvr1ml9', 5, 4, 'Belanjawan & Dasar Kerajaan', '["Hasil & perbelanjaan","Cukai"]', '2026-06-18 06:09:07.612');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl7k00317ddpen56xi2l', 'cmqj3nl7i002z7ddpezz8mxfo', 4, 1, 'Pengenalan Perakaunan', '["Persamaan perakaunan","Dokumen"]', '2026-06-18 06:09:07.616');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl7l00337ddp5770hubz', 'cmqj3nl7i002z7ddpezz8mxfo', 4, 2, 'Catatan Bergu & Lejar', '["Debit & kredit","Imbangan duga"]', '2026-06-18 06:09:07.618');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl7n00357ddpjm0ho6h5', 'cmqj3nl7i002z7ddpezz8mxfo', 5, 3, 'Penyata Kewangan', '["Penyata pendapatan","Kunci kira-kira"]', '2026-06-18 06:09:07.62');
INSERT INTO public."Topic" (id, "subjectId", form, chapter, title, subtopics, "createdAt") VALUES ('cmqj3nl7p00377ddpsbxf9n31', 'cmqj3nl7i002z7ddpezz8mxfo', 5, 4, 'Pelarasan & Penyesuaian Bank', '["Pelarasan akhir tahun","Penyata penyesuaian bank"]', '2026-06-18 06:09:07.622');


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
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl7s00397ddp61vxg45v', 'cmqj1mhub00007d001056mudp', 'cmqj1mhug00027d00ipajy9hy', NULL, 1, 'mcq', '1', 'Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?', '[{"key":"A","text":"Tanah subur untuk pertanian"},{"key":"B","text":"Kawasan tanah tinggi"},{"key":"C","text":"Perlombongan bijih timah"},{"key":"D","text":"Hutan tebal"}]', 'A', NULL, NULL, 1, false, 'Mesopotamia', 2025, 'past_paper', '2026-06-18 06:09:07.624', 'Curated seed content', '2026-06-18 06:09:07.623', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl7x003b7ddp11kbtmpr', 'cmqj1mhub00007d001056mudp', 'cmqj1mhup00087d008y6d5pk4', NULL, 1, 'mcq', '2', 'Mengapakah Piagam Madinah penting kepada masyarakat Madinah?', '[{"key":"A","text":"Menyatukan masyarakat pelbagai kaum"},{"key":"B","text":"Menyekat perdagangan"},{"key":"C","text":"Menghapus perhambaan"},{"key":"D","text":"Mewajibkan satu agama"}]', 'A', NULL, NULL, 1, true, 'Piagam Madinah', 2025, 'past_paper', '2026-06-18 06:09:07.629', 'Curated seed content', '2026-06-18 06:09:07.628', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl7z003d7ddpurd48ysv', 'cmqj1mhub00007d001056mudp', 'cmqj1mhun00067d00pxdovmn4', NULL, 2, 'structured', '1(a)', 'Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.', '[]', 'Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.', '1 markah setiap ciri (maks 2).', NULL, 2, false, 'Kerajaan maritim', 2025, 'past_paper', '2026-06-18 06:09:07.631', 'Curated seed content', '2026-06-18 06:09:07.63', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl81003f7ddpxm7peaap', 'cmqj1mhub00007d001056mudp', 'cmqj1mhuy000g7d007p3wv3p3', NULL, 2, 'essay', '5', 'Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.', '[]', NULL, 'Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.', '{"criteria":[{"name":"Pengenalan","maxMarks":2,"descriptor":"Latar belakang & konteks"},{"name":"Isi / Fakta","maxMarks":12,"descriptor":"Fakta tepat dengan huraian"},{"name":"Penerapan nilai / iktibar","maxMarks":4,"descriptor":"Nilai & iktibar relevan"},{"name":"Kesimpulan","maxMarks":2,"descriptor":"Rumusan padat"}]}', 20, true, 'Kemerdekaan 1957', 2025, 'past_paper', '2026-06-18 06:09:07.633', 'Curated seed content', '2026-06-18 06:09:07.632', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl83003h7ddpgc1so86c', 'cmqj1mhvm00117d00c6mndk42', 'cmqj1mhvn00137d00n2s2knrz', NULL, 2, 'structured', NULL, 'The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.', '[]', 'b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.', 'Discriminant = 0 (1m); substitute (1m); k = 9 (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.635', 'Curated seed content', '2026-06-18 06:09:07.634', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl85003j7ddp2cfkreim', 'cmqj1mhvm00117d00c6mndk42', 'cmqj1mhvr00177d00ev31ohoa', NULL, 1, 'mcq', NULL, 'A fair die is rolled once. What is the probability of getting a number greater than 4?', '[{"key":"A","text":"1/6"},{"key":"B","text":"1/3"},{"key":"C","text":"1/2"},{"key":"D","text":"2/3"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.637', 'Curated seed content', '2026-06-18 06:09:07.636', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl87003l7ddpyg3jeofa', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhvx001e7d009jr9ygn1', NULL, 1, 'structured', NULL, 'Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.', '[]', 'dy/dx = 6x − 5; at x = 2, gradient = 7.', 'Differentiate (1m); substitute (1m); answer (1m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.639', 'Curated seed content', '2026-06-18 06:09:07.639', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl89003n7ddplucm6aup', 'cmqj1mhw2001j7d00j2igr5u6', 'cmqj1mhw4001l7d00dt3a9p6z', NULL, 1, 'mcq', NULL, 'A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?', '[{"key":"A","text":"500 N"},{"key":"B","text":"1000 N"},{"key":"C","text":"2000 N"},{"key":"D","text":"4000 N"}]', 'C', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.641', 'Curated seed content', '2026-06-18 06:09:07.64', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8c003p7ddpxl9hr3kc', 'cmqj1mhw2001j7d00j2igr5u6', 'cmqj1mhw6001n7d00kjswo0vw', NULL, 3, 'structured', NULL, 'An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.', '[]', 'Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.', '1 markah setiap pemboleh ubah (maks 3).', NULL, 3, true, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.644', 'Curated seed content', '2026-06-18 06:09:07.644', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8e003r7ddprjpc14g0', 'cmqj1mhwb001s7d00e2zz5qs4', 'cmqj1mhwe001w7d00xp21cy8c', NULL, 2, 'structured', NULL, 'Explain why a solution of ammonia in water is alkaline.', '[]', 'Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.', 'OH⁻ ions present (1m); reaction with water (1m).', NULL, 2, true, NULL, 2023, 'past_paper', '2026-06-18 06:09:07.647', 'Curated seed content', '2026-06-18 06:09:07.646', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8h003t7ddpnfyny9jk', 'cmqj1mhwb001s7d00e2zz5qs4', 'cmqj1mhwe001w7d00xp21cy8c', NULL, 3, 'structured', NULL, 'In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.', '[]', 'Pink to colourless.', 'Correct colour change (1m).', NULL, 1, false, NULL, 2023, 'past_paper', '2026-06-18 06:09:07.649', 'Curated seed content', '2026-06-18 06:09:07.648', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8j003v7ddpwgv94854', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwm00237d00iggdate1', NULL, 2, 'essay', NULL, 'Describe the process of photosynthesis and explain its importance to living organisms.', '[]', NULL, 'Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.', NULL, 10, true, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.651', 'Curated seed content', '2026-06-18 06:09:07.65', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8l003x7ddpkpew3du5', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwk00217d001mjiet7f', NULL, 1, 'mcq', NULL, 'Which structure controls the movement of substances into and out of a cell?', '[{"key":"A","text":"Cell wall"},{"key":"B","text":"Plasma membrane"},{"key":"C","text":"Nucleus"},{"key":"D","text":"Vacuole"}]', 'B', NULL, NULL, 1, false, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.653', 'Curated seed content', '2026-06-18 06:09:07.653', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8n003z7ddpiw7urr16', 'cmqj1mhvc000s7d001cnxu7ul', 'cmqj1mhvg000w7d0023q9ugfb', NULL, 1, 'essay', NULL, 'Write a story that ends with: ''…and that was the day I learned the true meaning of courage.''', '[]', NULL, 'Assess language, content relevance and organisation.', NULL, 30, false, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.655', 'Curated seed content', '2026-06-18 06:09:07.655', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8p00417ddp537gdmpc', 'cmqj1mhv2000j7d0088otsv11', 'cmqj1mhv3000l7d001jn3mywz', NULL, 1, 'essay', NULL, 'Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.', '[]', NULL, 'Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.', NULL, 35, false, NULL, 2023, 'past_paper', '2026-06-18 06:09:07.657', 'Curated seed content', '2026-06-18 06:09:07.656', NULL, 'approved', false, 0.96);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8v00457ddpma8e4svg', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhvv001c7d00ln5ekkyz', 'cmqj3nl8r00437ddpty8nb09k', 1, 'structured', '1', 'Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).', '[]', 'fg(x) = 2x² + 3; gf(x) = (2x + 3)².', 'Each composite (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-18 06:09:07.663', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8x00477ddpsamhvnb0', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhw0001i7d004foxx666', 'cmqj3nl8r00437ddpty8nb09k', 1, 'structured', '2', 'In how many ways can 5 different books be arranged on a shelf?', '[]', '5! = 120.', '5! (1m); 120 (1m).', NULL, 2, false, NULL, 2025, 'past_paper', '2026-06-18 06:09:07.666', NULL, NULL, NULL, 'pending', false, 0.68);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl8z00497ddpu8l5oart', 'cmqj1mhvu001a7d00b2ndjo2k', 'cmqj1mhvy001g7d00csw0igo8', 'cmqj3nl8r00437ddpty8nb09k', 1, 'structured', '3', 'Find ∫(6x² − 4x) dx.', '[]', '2x³ − 2x² + c.', 'Each term (1m); +c (1m).', NULL, 2, true, NULL, 2025, 'past_paper', '2026-06-18 06:09:07.667', NULL, NULL, NULL, 'pending', false, 0.78);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl93004d7ddpeamxjfzk', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwk00217d001mjiet7f', 'cmqj3nl91004b7ddpwk57upof', 2, 'structured', '1', 'Explain how the structure of a red blood cell is adapted to its function.', '[]', 'Biconcave shape → large surface area; no nucleus → more space for haemoglobin.', 'Each adaptation + reason (1m).', NULL, 4, true, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.672', NULL, NULL, NULL, 'pending', false, 0.55);
INSERT INTO public."Question" (id, "subjectId", "topicId", "paperId", "paperNumber", "questionType", number, stem, options, answer, "markingScheme", rubric, marks, "isKbat", subtopic, year, source, "createdAt", "reviewNote", "reviewedAt", "reviewedById", status, "autoApproved", confidence) VALUES ('cmqj3nl96004f7ddpcwy1otx4', 'cmqj1mhwi001z7d00gyf8hqzd', 'cmqj1mhwn00257d00owri9tik', 'cmqj3nl91004b7ddpwk57upof', 2, 'structured', '2', 'Describe the path of a nerve impulse in a reflex arc.', '[]', 'Receptor → sensory neurone → relay neurone → motor neurone → effector.', 'Correct sequence (3m).', NULL, 3, false, NULL, 2024, 'past_paper', '2026-06-18 06:09:07.674', NULL, NULL, NULL, 'pending', false, 0.68);


--
-- Data for Name: Student; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mi0s003l7d00rj57198b', 'Vikhash', 'vikhash@student.spm.my', 5, '2026-06-18 05:12:17.596', '2026-06-18 06:09:07.775', true, '+60123456789', NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mi4k004k7d00jsul4gyy', 'Ahmad', 'ahmad@student.spm.my', 5, '2026-06-18 05:12:17.732', '2026-06-18 06:09:07.897', true, NULL, NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mi84005j7d005ou9vuzq', 'Siti Nurhaliza', 'siti@student.spm.my', 5, '2026-06-18 05:12:17.861', '2026-06-18 06:09:08.011', true, NULL, NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mibt006m7d003g92pw9f', 'Kumar Raj', 'kumar@student.spm.my', 4, '2026-06-18 05:12:17.993', '2026-06-18 06:09:08.133', true, NULL, NULL, NULL, NULL);
INSERT INTO public."Student" (id, name, email, form, "createdAt", "consentAt", "pdpaConsent", whatsapp, age, school, state) VALUES ('cmqj1mifl007n7d00lnizxlp3', 'Mei Ling', 'meiling@student.spm.my', 5, '2026-06-18 05:12:18.129', '2026-06-18 06:09:08.257', true, NULL, NULL, NULL, NULL);


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
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nleu005b7ddpli4g58zz', 'cmqj1mi0s003l7d00rj57198b', 'cmqj3nl7s00397ddp61vxg45v', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-10 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlf0005d7ddpi0hpjtla', 'cmqj1mi0s003l7d00rj57198b', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-12 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlf3005f7ddpzsubqv3r', 'cmqj1mi0s003l7d00rj57198b', 'cmqj3nl8p00417ddp537gdmpc', 'Jawapan contoh pelajar.', 22, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-13 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlf6005h7ddp8t7co6kj', 'cmqj1mi0s003l7d00rj57198b', 'cmqj3nl87003l7ddpyg3jeofa', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-15 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlf9005j7ddpfrrqe7kf', 'cmqj1mi0s003l7d00rj57198b', 'cmqj3nl8n003z7ddpiw7urr16', 'Jawapan contoh pelajar.', 13, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-16 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlhx00667ddpx7zbgbkj', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj3nl7x003b7ddp11kbtmpr', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-07 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nli200687ddpbekz9c4m', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj3nl8e003r7ddprjpc14g0', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-09 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nli5006a7ddp2bq78gk0', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj3nl7x003b7ddp11kbtmpr', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-10 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nli8006c7ddpj97uitul', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj3nl8e003r7ddprjpc14g0', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-12 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlib006e7ddp9uqqzcii', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj3nl7x003b7ddp11kbtmpr', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-13 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlie006g7ddpy1u0s2bs', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj3nl8e003r7ddprjpc14g0', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-15 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlig006i7ddp72ktaij3', 'cmqj1mi4k004k7d00jsul4gyy', 'cmqj3nl7x003b7ddp11kbtmpr', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-16 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nll500757ddpcivaj5i8', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl7z003d7ddpurd48ysv', 'Jawapan contoh pelajar.', 2, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-04 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nll800777ddp0zl02pt9', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl8n003z7ddpiw7urr16', 'Jawapan contoh pelajar.', 26, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-06 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nllb00797ddp4tofaeku', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl85003j7ddp2cfkreim', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-07 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nllf007b7ddpbaai176u', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl7x003b7ddp11kbtmpr', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-09 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlli007d7ddp5anprf21', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl8c003p7ddpxl9hr3kc', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-10 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlll007f7ddphz1iluaw', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl83003h7ddpgc1so86c', 'Jawapan contoh pelajar.', 2, 3, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-12 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nllo007h7ddp7fex3gu5', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl7s00397ddp61vxg45v', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-13 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nllr007j7ddpwh5ok9sw', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-15 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nllt007l7ddp9v3i4o1m', 'cmqj1mi84005j7d005ou9vuzq', 'cmqj3nl81003f7ddpxm7peaap', 'Jawapan contoh pelajar.', 18, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-16 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlof00827ddpb6ulhigm', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-06-01 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nloh00847ddpm8g2p5ch', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-06-03 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlok00867ddp51qra9el', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-04 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlon00887ddp6tvd3ju6', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-06 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlor008a7ddpj5vv27mi', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-07 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlov008c7ddpgtv5ls1y', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-09 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nloy008e7ddp4dn4a90e', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-10 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlp0008g7ddpau0i6hj2', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-12 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlp3008i7ddpnpev1mqo', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-13 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlp6008k7ddptqqj56gy', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-15 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlp9008m7ddpplik2cyt', 'cmqj1mibt006m7d003g92pw9f', 'cmqj3nl89003n7ddplucm6aup', 'C', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-16 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlry00977ddpzpi2w5uk', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8e003r7ddprjpc14g0', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 60, '2026-05-29 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nls200997ddppcnk6ni6', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl7x003b7ddp11kbtmpr', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 80, '2026-05-31 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nls5009b7ddpw02tx7vt', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8n003z7ddpiw7urr16', 'Jawapan contoh pelajar.', 19, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 100, '2026-06-01 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nls9009d7ddpxjfddgv0', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8h003t7ddpnfyny9jk', 'Jawapan contoh pelajar.', 1, 1, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 120, '2026-06-03 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlsc009f7ddpequexcb7', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl7z003d7ddpurd48ysv', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 140, '2026-06-04 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlse009h7ddpv6dwphps', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8p00417ddp537gdmpc', 'Jawapan contoh pelajar.', 14, 35, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 160, '2026-06-06 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlsh009j7ddpqnx598v3', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8j003v7ddpwgv94854', 'Jawapan contoh pelajar.', 5, 10, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 180, '2026-06-07 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlsk009l7ddpaco0cw26', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl81003f7ddpxm7peaap', 'Jawapan contoh pelajar.', 12, 20, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 200, '2026-06-09 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlsn009n7ddpkqjgmksx', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl7s00397ddp61vxg45v', 'A', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 220, '2026-06-10 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlsq009p7ddpd1alju8a', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8l003x7ddpkpew3du5', 'B', 1, 1, NULL, true, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 240, '2026-06-12 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlss009r7ddp2el1y2rb', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8e003r7ddprjpc14g0', 'Jawapan contoh pelajar.', 1, 2, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 260, '2026-06-13 18:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlsv009t7ddpudrn1nsy', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl7x003b7ddp11kbtmpr', 'A', 0, 1, NULL, false, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 280, '2026-06-15 06:09:07.775');
INSERT INTO public."Attempt" (id, "studentId", "questionId", answer, score, "maxScore", band, "isCorrect", feedback, "gradedByAi", "timeSpentSec", "createdAt") VALUES ('cmqj3nlsy009v7ddpyg78zjfh', 'cmqj1mifl007n7d00lnizxlp3', 'cmqj3nl8n003z7ddpiw7urr16', 'Jawapan contoh pelajar.', 14, 30, NULL, NULL, '{"summary":"Seeded attempt.","strengths":[],"improvements":[],"criteria":[]}', false, 300, '2026-06-16 18:09:07.775');


--
-- Data for Name: Bookmark; Type: TABLE DATA; Schema: public; Owner: -
--



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
-- Data for Name: GeneratedQuestion; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: KnowledgeDoc; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj1mhy0003f7d00nl55prki', 'Photosynthesis — key concepts', 'cmqj1mhwi001z7d00gyf8hqzd', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-18 05:12:17.496');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj1mhy2003h7d00vke5w7ez', 'Acids, bases & salts — essentials', 'cmqj1mhwb001s7d00e2zz5qs4', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-18 05:12:17.498');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj1mhy4003j7d00cgyno7xe', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqj1mhub00007d001056mudp', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-18 05:12:17.5');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj3nl98004h7ddptsbawr6t', 'Photosynthesis — key concepts', 'cmqj1mhwi001z7d00gyf8hqzd', 4, 'summary', 'Seed (sample notes)', 'Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).', '2026-06-18 06:09:07.676');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj3nl9c004j7ddpj5bi8f2t', 'Acids, bases & salts — essentials', 'cmqj1mhwb001s7d00e2zz5qs4', 4, 'summary', 'Seed (sample notes)', 'An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.', '2026-06-18 06:09:07.68');
INSERT INTO public."KnowledgeDoc" (id, title, "subjectId", form, kind, source, content, "createdAt") VALUES ('cmqj3nl9d004l7ddpvscoda8b', 'Pembinaan Negara dan Bangsa — Kemerdekaan 1957', 'cmqj1mhub00007d001056mudp', 5, 'note', 'Seed (sample notes)', 'Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.', '2026-06-18 06:09:07.682');


--
-- Data for Name: MockPaper; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: PasswordReset; Type: TABLE DATA; Schema: public; Owner: -
--



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
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nlem00577ddpspsmulkr', 'cmqj1mi0s003l7d00rj57198b', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-13 06:09:07.775');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nleq00597ddpn871wljb', 'cmqj1mi0s003l7d00rj57198b', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-08 06:09:07.775');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nlhv00647ddpg0wr97wi', 'cmqj1mi4k004k7d00jsul4gyy', 99, 'MYR', 'card', 'paid', 'Monthly Premium — May 2026', '2026-06-08 06:09:07.775');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nll100717ddpaeyo9fl7', 'cmqj1mi84005j7d005ou9vuzq', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-03 06:09:07.775');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nll200737ddpz79ydfox', 'cmqj1mi84005j7d005ou9vuzq', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-06-06 06:09:07.775');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nloc00807ddp4ozuhzrb', 'cmqj1mibt006m7d003g92pw9f', 99, 'MYR', 'ewallet', 'pending', 'Monthly Premium — Jun 2026', '2026-05-29 06:09:07.775');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nlrt00937ddpwek1cl36', 'cmqj1mifl007n7d00lnizxlp3', 99, 'MYR', 'fpx', 'paid', 'Monthly Premium — Jun 2026', '2026-05-24 06:09:07.775');
INSERT INTO public."Payment" (id, "studentId", amount, currency, method, status, description, "paidAt") VALUES ('cmqj3nlrv00957ddp2oiqen0b', 'cmqj1mifl007n7d00lnizxlp3', 899, 'MYR', 'fpx', 'paid', 'Annual Plan 2026', '2026-06-04 06:09:07.775');


--
-- Data for Name: PushSubscription; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ReviewItem; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: StudySession; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mi4i004j7d0025l10lqu', 'cmqj1mi0s003l7d00rj57198b', NULL, 1200, 5, '2026-06-18 05:12:17.73');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mi81005i7d00q4bo1wcv', 'cmqj1mi4k004k7d00jsul4gyy', NULL, 1800, 7, '2026-06-18 05:12:17.858');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mibr006l7d005ic6diwn', 'cmqj1mi84005j7d005ou9vuzq', NULL, 2400, 9, '2026-06-18 05:12:17.992');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mifj007m7d00shm0wlll', 'cmqj1mibt006m7d003g92pw9f', NULL, 3000, 11, '2026-06-18 05:12:18.127');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj1mijf008v7d0066awun6i', 'cmqj1mifl007n7d00lnizxlp3', NULL, 3600, 13, '2026-06-18 05:12:18.268');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj3nlfa005l7ddpug9091v4', 'cmqj1mi0s003l7d00rj57198b', NULL, 1200, 5, '2026-06-18 06:09:07.895');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj3nlii006k7ddphoqml5wg', 'cmqj1mi4k004k7d00jsul4gyy', NULL, 1800, 7, '2026-06-18 06:09:08.01');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj3nllv007n7ddp29fxwf3a', 'cmqj1mi84005j7d005ou9vuzq', NULL, 2400, 9, '2026-06-18 06:09:08.132');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj3nlpb008o7ddpxxrpan06', 'cmqj1mibt006m7d003g92pw9f', NULL, 3000, 11, '2026-06-18 06:09:08.256');
INSERT INTO public."StudySession" (id, "studentId", "subjectId", "durationSec", "questionsDone", "createdAt") VALUES ('cmqj3nlt0009x7ddpkj6d3pu3', 'cmqj1mifl007n7d00lnizxlp3', NULL, 3600, 13, '2026-06-18 06:09:08.389');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mi0o003k7d00tah479c8', 'admin@spm.my', 'Admin Cikgu', 'admin', 'd80ee3ca5b676ea0e39758660c234919:344b9971ecc0361fe49a686d9423e48c7703fa769a3c1f14bcfcdb485cb81eb0c62fc1ed75cf2f026d6ba9312a42ae63d7e43d2c4957cd39b309c6080a10b2a6', NULL, '2026-06-18 05:12:17.593');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mi33003n7d00wnugwk2r', 'vikhash@student.spm.my', 'Vikhash', 'student', '08cb18ac628d77042b928ad35430e38c:ee03d8491242c324f7614b8dd584cdb2492f803db204ecf2bd503cbfb22fa04e9006ddf4cc6f96821889e835e5f9b092f119c971df32daf58d28643e462d645e', 'cmqj1mi0s003l7d00rj57198b', '2026-06-18 05:12:17.679');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mi6u004m7d00ly751rcq', 'ahmad@student.spm.my', 'Ahmad', 'student', '9d94c6ed14ae1e74c8a0ad0519d4b31d:85179a987dc3303ddf3d2971e241d921bec6634ee1756892c24c88b08b0ae66d59e9c784cdb9a7173c9d33a4dce7e323e742242fcd33cd74859c85a758eaff56', 'cmqj1mi4k004k7d00jsul4gyy', '2026-06-18 05:12:17.814');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1miaf005l7d00ld52zwnd', 'siti@student.spm.my', 'Siti Nurhaliza', 'student', '34c768422f6f93b4df079a6ff11aa5f6:154856633748c67b71462901a00048b1fb7f8b3134ad8acc35c2a734c313460c6ee76e405d57f10595997eec6cad9bd6ea93d4388412c4f4bae42d7dd745443e', 'cmqj1mi84005j7d005ou9vuzq', '2026-06-18 05:12:17.944');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mie7006o7d00dc6or38w', 'kumar@student.spm.my', 'Kumar Raj', 'student', 'b74e6e63455075502e3a83b38cccbfd7:3a4071493d91271d2b195163cd6dad86a7e907cbc985c725dea317f7f2dc41ad352dbf878d0d0e7d88dd89eb1dfa8f3d41a6a88f4a85106eb72eb2dd8621e50d', 'cmqj1mibt006m7d003g92pw9f', '2026-06-18 05:12:18.079');
INSERT INTO public."User" (id, email, name, role, password, "studentId", "createdAt") VALUES ('cmqj1mihu007p7d004vfvig1z', 'meiling@student.spm.my', 'Mei Ling', 'student', 'c38bf8a0426477888838237f3d2be4de:d5fdf56574364ca579d467537776e2dea32efd1676dc29c37f5db2d486577037942e09ac40b40ee46f94d5940be5cc350a37f178685c41eb812736be94d222b9', 'cmqj1mifl007n7d00lnizxlp3', '2026-06-18 05:12:18.21');


--
-- Data for Name: Waitlist; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- PostgreSQL database dump complete
--


