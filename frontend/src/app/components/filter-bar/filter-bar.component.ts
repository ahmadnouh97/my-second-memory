import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NgFor, NgIf } from '@angular/common';
import {
  IonChip,
  IonIcon,
  IonLabel,
  IonSelect,
  IonSelectOption,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { close } from 'ionicons/icons';

export interface FilterState {
  content_type?: string;
  tags: string[];
  date_from?: string;
  date_to?: string;
}

@Component({
  selector: 'app-filter-bar',
  templateUrl: 'filter-bar.component.html',
  standalone: true,
  imports: [NgFor, NgIf, FormsModule, IonChip, IonIcon, IonLabel, IonSelect, IonSelectOption],
})
export class FilterBarComponent implements OnInit {
  @Input() allTags: string[] = [];
  @Output() filterChanged = new EventEmitter<FilterState>();

  selectedType = '';
  selectedTags: string[] = [];
  dateFrom = '';
  dateTo = '';

  constructor() {
    addIcons({ close });
  }

  ngOnInit(): void {}

  toggleTag(tag: string): void {
    const idx = this.selectedTags.indexOf(tag);
    if (idx >= 0) {
      this.selectedTags = [...this.selectedTags.slice(0, idx), ...this.selectedTags.slice(idx + 1)];
    } else {
      this.selectedTags = [...this.selectedTags, tag];
    }
    this.emit();
  }

  isTagSelected(tag: string): boolean {
    return this.selectedTags.includes(tag);
  }

  onTypeChange(): void {
    this.emit();
  }

  clearFilters(): void {
    this.selectedType = '';
    this.selectedTags = [];
    this.dateFrom = '';
    this.dateTo = '';
    this.emit();
  }

  private emit(): void {
    this.filterChanged.emit({
      content_type: this.selectedType || undefined,
      tags: this.selectedTags,
      date_from: this.dateFrom || undefined,
      date_to: this.dateTo || undefined,
    });
  }
}
