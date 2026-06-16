import { prisma } from "./db";

// POC: a single demo student. In production this comes from auth/session.
export async function getCurrentStudent() {
  let student = await prisma.student.findFirst({ orderBy: { createdAt: "asc" } });
  if (!student) {
    student = await prisma.student.create({
      data: { name: "Ahmad", email: "ahmad@student.spm.my", form: 5 },
    });
  }
  return student;
}
