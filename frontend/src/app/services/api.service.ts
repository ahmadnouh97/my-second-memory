import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  ExtractPreview,
  Item,
  PaginatedResponse,
} from '../models/item.model';

export interface ItemFilters {
  tags?: string[];
  content_type?: string;
  date_from?: string;
  date_to?: string;
  page?: number;
  limit?: number;
}

export interface ItemUpdate {
  title?: string;
  summary?: string;
  tags?: string[];
  thumbnail_url?: string;
}

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);
  private readonly base = environment.apiUrl;

  extractUrl(url: string): Observable<ExtractPreview> {
    return this.http.post<ExtractPreview>(`${this.base}/api/items/extract`, { url });
  }

  createItem(data: Partial<Item> & { url: string; title: string; content_type: string }): Observable<Item> {
    return this.http.post<Item>(`${this.base}/api/items`, data);
  }

  listItems(filters: ItemFilters = {}): Observable<PaginatedResponse> {
    let params = new HttpParams();
    if (filters.content_type) params = params.set('content_type', filters.content_type);
    if (filters.date_from) params = params.set('date_from', filters.date_from);
    if (filters.date_to) params = params.set('date_to', filters.date_to);
    if (filters.page) params = params.set('page', filters.page.toString());
    if (filters.limit) params = params.set('limit', filters.limit.toString());
    if (filters.tags) {
      filters.tags.forEach((t) => (params = params.append('tags', t)));
    }
    return this.http.get<PaginatedResponse>(`${this.base}/api/items`, { params });
  }

  searchItems(
    q: string,
    filters: Omit<ItemFilters, 'page' | 'limit'> = {}
  ): Observable<Item[]> {
    let params = new HttpParams().set('q', q);
    if (filters.content_type) params = params.set('content_type', filters.content_type);
    if (filters.tags) {
      filters.tags.forEach((t) => (params = params.append('tags', t)));
    }
    return this.http.get<Item[]>(`${this.base}/api/items/search`, { params });
  }

  getItem(id: string): Observable<Item> {
    return this.http.get<Item>(`${this.base}/api/items/${id}`);
  }

  updateItem(id: string, data: ItemUpdate): Observable<Item> {
    return this.http.put<Item>(`${this.base}/api/items/${id}`, data);
  }

  deleteItem(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/api/items/${id}`);
  }

  /**
   * Opens an SSE connection to the chat endpoint.
   * Returns an EventSource that emits parsed JSON events.
   */
  chatStream(
    message: string,
    history: { role: string; content: string }[]
  ): EventSource {
    // SSE requires GET or a POST-compatible approach.
    // We'll use a POST via fetch + ReadableStream in the chat page instead.
    throw new Error('Use chatStreamFetch instead');
  }

  async *chatStreamFetch(
    message: string,
    history: { role: string; content: string }[]
  ): AsyncGenerator<{ type: string; content?: string; items?: Item[] }> {
    const response = await fetch(`${this.base}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, history }),
    });

    if (!response.body) throw new Error('No response body');
    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop() ?? '';
      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = line.slice(6).trim();
          if (data === '[DONE]') return;
          try {
            yield JSON.parse(data);
          } catch {
            // ignore malformed lines
          }
        }
      }
    }
  }
}
