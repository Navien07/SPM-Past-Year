import { PrismaClient } from "@prisma/client";

// One PrismaClient per server instance (never per-request). Assigning to the
// global keeps a single client across hot reloads in dev AND across module
// evaluations in serverless, so a function instance holds a single pool.
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["error", "warn"] : ["error"],
  });

globalForPrisma.prisma = prisma;
