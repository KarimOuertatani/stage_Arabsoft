import { Component, OnInit, Inject, ViewChild, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import { ApiService } from '../services/api.service';
import { Categorie } from '../models/categorie.model';
import { Utilisateur } from '../models/utilisateur.model';

@Component({
  selector: 'app-categories',
  templateUrl: './categories.component.html',
  styleUrls: ['./categories.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatTableModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSidenavModule,
    MatListModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule
  ]
})
export class CategoriesComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;

  categories: Categorie[] = [];
  categorieColumns = ['id', 'nom', 'actions'];
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  isSidenavCollapsed: boolean = false;
  windowWidth: number = window.innerWidth;

  constructor(private apiService: ApiService, private dialog: MatDialog, private router: Router) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event): void {
    this.windowWidth = window.innerWidth;
    this.isSidenavCollapsed = this.windowWidth <= 599;
  }

  ngOnInit() {
    this.isShowAlert = localStorage.getItem('showAlert') !== 'false';
    this.isDarkTheme = localStorage.getItem('theme') === 'dark';
    this.isSidenavCollapsed = this.windowWidth <= 599;

    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser = user;
        this.loadCategories();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      }
    });

    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  private loadCategories() {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.getCategories().subscribe({
      next: (categories) => {
        this.categories = categories;
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des catégories:', err);
        this.errorMessage = 'Failed to load categories. Please try again.';
        this.isLoading = false;
      }
    });
  }

  openCreateDialog() {
    const dialogRef = this.dialog.open(CategorieDialogComponent, {
      width: '400px',
      data: { id: null, nom: '' }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result && result.nom) {
        this.isLoading = true;
        this.apiService.createCategorie(result).subscribe({
          next: () => {
            this.loadCategories();
          },
          error: (err) => {
            console.error('Erreur lors de la création de la catégorie:', err);
            this.errorMessage = 'Failed to create category. Please try again.';
            this.isLoading = false;
          }
        });
      }
    });
  }

  openEditDialog(categorie: Categorie) {
    const dialogRef = this.dialog.open(CategorieDialogComponent, {
      width: '400px',
      data: { ...categorie }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result && result.nom) {
        this.isLoading = true;
        this.apiService.updateCategorie(categorie.id, result).subscribe({
          next: () => {
            this.loadCategories();
          },
          error: (err) => {
            console.error('Erreur lors de la mise à jour de la catégorie:', err);
            this.errorMessage = 'Failed to update category. Please try again.';
            this.isLoading = false;
          }
        });
      }
    });
  }

  openDeleteDialog(id: number, nom: string) {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      width: '350px',
      data: { message: `Are you sure you want to delete category ${nom}?` }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.deleteCategorie(id);
      }
    });
  }

  deleteCategorie(id: number) {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.deleteCategorie(id).subscribe({
      next: () => {
        this.loadCategories();
      },
      error: (err) => {
        console.error('Erreur lors de la suppression de la catégorie:', err);
        this.errorMessage = 'Failed to delete category. Please try again.';
        this.isLoading = false;
      }
    });
  }

  onAlertDismiss(): void {
    this.isShowAlert = false;
    localStorage.setItem('showAlert', 'false');
  }

  toggleTheme(): void {
    this.isDarkTheme = !this.isDarkTheme;
    localStorage.setItem('theme', this.isDarkTheme ? 'dark' : 'light');
    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  toggleSidenav(): void {
    this.isSidenavCollapsed = !this.isSidenavCollapsed;
    this.sidenav.toggle();
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('theme');
    localStorage.removeItem('showAlert');
    this.router.navigate(['/login']);
  }

  retry(): void {
    this.loadCategories();
  }
}

@Component({
  selector: 'app-categorie-dialog',
  template: `
    <h1 mat-dialog-title>{{ data.id ? 'Edit Category' : 'Add Category' }}</h1>
    <div mat-dialog-content>
      <mat-form-field appearance="outline">
        <mat-label>Name</mat-label>
        <input matInput [(ngModel)]="data.nom" required>
        <mat-error *ngIf="!data.nom">Name is required</mat-error>
      </mat-form-field>
    </div>
    <div mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close()">Cancel</button>
      <button mat-raised-button color="primary" (click)="dialogRef.close(data)" [disabled]="!data.nom">Save</button>
    </div>
  `,
  standalone: true,
  imports: [
    FormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule
  ]
})
export class CategorieDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<CategorieDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: Categorie
  ) {}
}

@Component({
  selector: 'app-confirm-dialog',
  template: `
    <h2 mat-dialog-title>Confirm Deletion</h2>
    <mat-dialog-content>{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close(false)">Cancel</button>
      <button mat-button color="warn" (click)="dialogRef.close(true)">Delete</button>
    </mat-dialog-actions>
  `,
  standalone: true,
  imports: [MatDialogModule, MatButtonModule]
})
export class ConfirmDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ConfirmDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { message: string }
  ) {}
}