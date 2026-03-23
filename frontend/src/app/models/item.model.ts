export type ContentType = 'youtube' | 'instagram' | 'article' | 'link';

export interface Item {
  id: string;
  url: string;
  title: string;
  summary: string | null;
  content_type: ContentType;
  tags: string[];
  thumbnail_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface ExtractPreview {
  url: string;
  content_type: ContentType;
  title: string;
  summary: string;
  tags: string[];
  thumbnail_url: string | null;
  content: string | null;
  source_meta: Record<string, unknown> | null;
}

export interface PaginatedResponse {
  items: Item[];
  total: number;
  page: number;
  limit: number;
}

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
  items?: Item[];
}

export interface ChatStreamEvent {
  type: 'text' | 'items';
  content?: string;
  items?: Item[];
}
