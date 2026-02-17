/**
 * Storage API types for plugins
 *
 * These types allow plugins to use the plugin-extensible storage system.
 * Core provides SQLite/PostgreSQL abstraction - plugins define Zod schemas.
 */

import type { z } from "zod";

// ============================================================================
// Filter Types
// ============================================================================

export type FilterOperator =
  | "$eq"
  | "$ne"
  | "$gt"
  | "$gte"
  | "$lt"
  | "$lte"
  | "$in"
  | "$nin"
  | "$contains"
  | "$startsWith"
  | "$endsWith"
  | "$regex";

export type FilterCondition<T> =
  | T
  | { $eq: T }
  | { $ne: T }
  | { $gt: T }
  | { $gte: T }
  | { $lt: T }
  | { $lte: T }
  | { $in: T[] }
  | { $nin: T[] }
  | (T extends Array<infer U> ? { $contains: U } : never)
  | (T extends string ? { $startsWith: string } | { $endsWith: string } | { $regex: string } : never);

export type Filter<T> = {
  [K in string & keyof T]?: FilterCondition<T[K]>;
};

export type OrderDirection = "asc" | "desc";

// ============================================================================
// Repository (CRUD operations)
// ============================================================================

export interface Repository<T extends Record<string, unknown>> {
  insert(data: T): Promise<T>;
  insertMany(data: T[]): Promise<T[]>;
  findById(id: string): Promise<T | null>;
  findFirst(filter: Filter<T>): Promise<T | null>;
  findMany(filter?: Filter<T>): Promise<T[]>;
  update(id: string, data: Partial<T>): Promise<T>;
  updateMany(filter: Filter<T>, data: Partial<T>): Promise<number>;
  delete(id: string): Promise<boolean>;
  deleteMany(filter: Filter<T>): Promise<number>;
  count(filter?: Filter<T>): Promise<number>;
  exists(id: string): Promise<boolean>;
  query(): QueryBuilder<T>;
  raw(sql: string, params?: unknown[]): Promise<unknown[]>;
  transaction<R>(fn: (repo: Repository<T>) => Promise<R>): Promise<R>;
}

// ============================================================================
// Query Builder
// ============================================================================

export interface QueryBuilder<T extends Record<string, unknown>> {
  where(filter: Filter<T>): QueryBuilder<T>;
  orderBy(field: keyof T, direction?: OrderDirection): QueryBuilder<T>;
  limit(count: number): QueryBuilder<T>;
  offset(count: number): QueryBuilder<T>;
  select<K extends keyof T>(...fields: K[]): QueryBuilder<Pick<T, K>>;
  execute(): Promise<T[]>;
}

// ============================================================================
// Table Schema
// ============================================================================

export interface TableIndex {
  fields: string[];
  unique?: boolean;
}

export interface TableSchema {
  schema: z.ZodObject<Record<string, z.ZodTypeAny>>;
  primaryKey: string;
  indexes?: TableIndex[];
}

export interface PluginSchema {
  namespace: string;
  version: number;
  tables: Record<string, TableSchema>;
}

// ============================================================================
// Storage API
// ============================================================================

export interface StorageApi {
  readonly driver: "sqlite" | "postgres";
  register(schema: PluginSchema): Promise<void>;
  getRepository<T extends Record<string, unknown>>(namespace: string, tableName: string): Repository<T>;
  isRegistered(namespace: string): boolean;
  getVersion(namespace: string): Promise<number>;
  raw(sql: string, params?: unknown[]): Promise<unknown[]>;
  transaction<R>(fn: (storage: StorageApi) => Promise<R>): Promise<R>;
}
