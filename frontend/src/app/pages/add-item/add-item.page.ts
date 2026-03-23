import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NgIf, NgFor } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import {
  IonBackButton,
  IonButton,
  IonButtons,
  IonChip,
  IonContent,
  IonHeader,
  IonIcon,
  IonInput,
  IonItem,
  IonLabel,
  IonSpinner,
  IonTextarea,
  IonTitle,
  IonToolbar,
  IonNote,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { close, add, checkmark } from 'ionicons/icons';
import { ApiService } from '../../services/api.service';
import { ExtractPreview } from '../../models/item.model';

type PageState = 'input' | 'extracting' | 'preview' | 'saving';

@Component({
  selector: 'app-add-item',
  templateUrl: 'add-item.page.html',
  standalone: true,
  imports: [
    NgIf, NgFor, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonButtons, IonBackButton,
    IonContent, IonItem, IonLabel, IonInput, IonTextarea,
    IonButton, IonIcon, IonChip, IonSpinner, IonNote,
  ],
})
export class AddItemPage implements OnInit {
  state: PageState = 'input';
  url = '';
  preview: ExtractPreview | null = null;
  errorMsg = '';

  // Editable preview fields
  editTitle = '';
  editSummary = '';
  editTags: string[] = [];
  newTag = '';

  constructor(
    private api: ApiService,
    private router: Router,
    private route: ActivatedRoute,
    private toastCtrl: ToastController,
  ) {
    addIcons({ close, add, checkmark });
  }

  ngOnInit(): void {
    // Pre-fill URL from share intent or query param
    this.route.queryParams.subscribe((params) => {
      if (params['url']) {
        this.url = params['url'];
        this.extract();
      }
    });
  }

  async extract(): Promise<void> {
    if (!this.url.trim()) return;
    this.state = 'extracting';
    this.errorMsg = '';

    this.api.extractUrl(this.url.trim()).subscribe({
      next: (data) => {
        this.preview = data;
        this.editTitle = data.title;
        this.editSummary = data.summary;
        this.editTags = [...data.tags];
        this.state = 'preview';
      },
      error: (err) => {
        this.errorMsg = 'Could not extract metadata. Check the URL and try again.';
        this.state = 'input';
      },
    });
  }

  addTag(): void {
    const tag = this.newTag.trim().toLowerCase().replace(/\s+/g, '-');
    if (tag && !this.editTags.includes(tag)) {
      this.editTags = [...this.editTags, tag];
    }
    this.newTag = '';
  }

  removeTag(tag: string): void {
    this.editTags = this.editTags.filter((t) => t !== tag);
  }

  async save(): Promise<void> {
    if (!this.preview) return;
    this.state = 'saving';

    this.api.createItem({
      url: this.preview.url,
      title: this.editTitle,
      summary: this.editSummary,
      content_type: this.preview.content_type,
      tags: this.editTags,
      thumbnail_url: this.preview.thumbnail_url ?? undefined,
      content: this.preview.content ?? undefined,
      source_meta: this.preview.source_meta ?? undefined,
    } as any).subscribe({
      next: async (item) => {
        const toast = await this.toastCtrl.create({
          message: 'Saved to your memory!',
          duration: 2000,
          color: 'success',
        });
        toast.present();
        this.router.navigate(['/home'], { replaceUrl: true });
      },
      error: () => {
        this.state = 'preview';
        this.errorMsg = 'Failed to save. Please try again.';
      },
    });
  }

  reset(): void {
    this.state = 'input';
    this.url = '';
    this.preview = null;
    this.errorMsg = '';
  }
}
