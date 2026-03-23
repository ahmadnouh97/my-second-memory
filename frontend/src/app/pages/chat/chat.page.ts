import { Component, ViewChild, ElementRef } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NgFor, NgIf } from '@angular/common';
import { Router } from '@angular/router';
import {
  IonBackButton,
  IonButton,
  IonButtons,
  IonContent,
  IonFooter,
  IonHeader,
  IonIcon,
  IonInput,
  IonItem,
  IonSpinner,
  IonTitle,
  IonToolbar,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { send } from 'ionicons/icons';
import { ApiService } from '../../services/api.service';
import { ChatMessage, Item } from '../../models/item.model';
import { ChatItemWidgetComponent } from '../../components/chat-item-widget/chat-item-widget.component';

@Component({
  selector: 'app-chat',
  templateUrl: 'chat.page.html',
  standalone: true,
  imports: [
    NgFor, NgIf, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonButtons, IonBackButton,
    IonContent, IonFooter, IonItem, IonInput,
    IonButton, IonIcon, IonSpinner,
    ChatItemWidgetComponent,
  ],
})
export class ChatPage {
  @ViewChild(IonContent) content!: IonContent;

  messages: ChatMessage[] = [];
  inputText = '';
  isStreaming = false;

  constructor(private api: ApiService) {
    addIcons({ send });
    this.messages = [
      {
        role: 'assistant',
        content: "Hi! I'm your memory assistant. Ask me anything about your saved content.",
      },
    ];
  }

  async send(): Promise<void> {
    const text = this.inputText.trim();
    if (!text || this.isStreaming) return;

    this.inputText = '';
    this.messages = [...this.messages, { role: 'user', content: text }];
    this.scrollToBottom();

    const assistantMsg: ChatMessage = { role: 'assistant', content: '', items: [] };
    this.messages = [...this.messages, assistantMsg];
    this.isStreaming = true;

    const history = this.messages.slice(0, -2).map((m) => ({
      role: m.role,
      content: m.content,
    }));

    try {
      for await (const event of this.api.chatStreamFetch(text, history)) {
        if (event.type === 'text' && event.content) {
          assistantMsg.content += event.content;
          // Remove ITEMS_JSON from displayed text
          assistantMsg.content = assistantMsg.content.replace(/ITEMS_JSON:.*$/s, '').trimEnd();
          this.messages = [...this.messages];
          this.scrollToBottom();
        } else if (event.type === 'items' && event.items) {
          assistantMsg.items = event.items;
          this.messages = [...this.messages];
          this.scrollToBottom();
        }
      }
    } catch (err) {
      assistantMsg.content += '\n\n[Error: Could not reach the server.]';
      this.messages = [...this.messages];
    }

    this.isStreaming = false;
    this.scrollToBottom();
  }

  private scrollToBottom(): void {
    setTimeout(() => this.content?.scrollToBottom(300), 50);
  }
}
