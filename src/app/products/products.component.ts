import { Component, OnInit, ViewChild, HostListener, Inject } from '@angular/core';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Produit } from '../models/produit.model';
import { Utilisateur } from '../models/utilisateur.model';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { FormsModule } from '@angular/forms';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatPaginatorModule, MatPaginator } from '@angular/material/paginator';

@Component({
  selector: 'app-products',
  templateUrl: './products.component.html',
  styleUrls: ['./products.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatListModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule,
    MatFormFieldModule,
    MatInputModule,
    FormsModule,
    MatDialogModule,
    MatPaginatorModule
  ]
})
export class ProductsComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;
  @ViewChild(MatPaginator) paginator!: MatPaginator;

  produits: Produit[] = [];
  filteredProduits = new MatTableDataSource<Produit>([]);
  searchQuery: string = '';
  produitColumns = ['image', 'id', 'nom', 'categorie', 'prix', 'quantite', 'actions'];
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  isSidenavCollapsed: boolean = false;
  windowWidth: number = window.innerWidth;

  productChartData: ChartData<'pie'> = {
    labels: [],
    datasets: [
      {
        data: [],
        backgroundColor: ['#2563eb', '#14b8a6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6b7280'],
        borderColor: '#ffffff',
        borderWidth: 2
      }
    ]
  };

  chartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'right',
        labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } }
      },
      tooltip: {
        enabled: true,
        backgroundColor: '#1f2a44',
        titleFont: { family: 'Inter, Roboto, sans-serif' },
        bodyFont: { family: 'Inter, Roboto, sans-serif' }
      }
    }
  };

  constructor(private apiService: ApiService, private router: Router, private dialog: MatDialog) {}

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
        this.loadProducts();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      }
    });

    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  ngAfterViewInit() {
    this.filteredProduits.paginator = this.paginator;
  }

  private loadProducts() {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.getProduits().subscribe({
      next: (produits) => {
        this.produits = produits;
        this.filteredProduits.data = produits;
        this.loadProductImages();
        this.updateChartData();
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des produits:', err);
        this.errorMessage = 'Failed to load products. Please try again.';
        this.isLoading = false;
      }
    });
  }

  private loadProductImages() {
    this.produits.forEach(produit => {
      if (produit.id) {
        this.apiService.getProduitImage(produit.id).subscribe({
          next: (blob) => {
            const reader = new FileReader();
            reader.onloadend = () => {
              produit.image = reader.result as string; // Base64 string
            };
            reader.readAsDataURL(blob);
          },
          error: (err) => {
            console.error(`Erreur lors du chargement de l'image pour le produit ${produit.id}:`, err);
            produit.image = 'assets/images/default-product.png'; // Image par défaut
          }
        });
      }
    });
  }

  private updateChartData() {
    const categoryCounts = new Map<string, number>();
    this.produits.forEach(produit => {
      const category = produit.categorie.nom;
      categoryCounts.set(category, (categoryCounts.get(category) || 0) + 1);
    });
    this.productChartData.labels = Array.from(categoryCounts.keys());
    this.productChartData.datasets[0].data = Array.from(categoryCounts.values());
  }

  filterProducts() {
    if (!this.searchQuery.trim()) {
      this.filteredProduits.data = this.produits;
    } else {
      const query = this.searchQuery.toLowerCase();
      this.filteredProduits.data = this.produits.filter(produit =>
        produit.nom.toLowerCase().includes(query) ||
        produit.categorie.nom.toLowerCase().includes(query)
      );
    }
  }

  openImageDialog(imageSrc: string, productName: string) {
    this.dialog.open(ImageDialogComponent, {
      data: { imageSrc, productName },
      panelClass: 'image-dialog'
    });
  }

  updateProduct(id: number) {
    console.log(`Update product with ID: ${id}`);
    // Implémenter la logique de mise à jour (ex. : naviguer vers un formulaire)
  }

  deleteProduct(id: number) {
    console.log(`Delete product with ID: ${id}`);
    // Implémenter la logique de suppression
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
    this.loadProducts();
  }
}

@Component({
  selector: 'app-image-dialog',
  template: `
    <div class="dialog-content">
      <h2 mat-dialog-title>{{ data.productName }}</h2>
      <mat-dialog-content>
        <img [src]="data.imageSrc" alt="Product Image" class="dialog-image">
      </mat-dialog-content>
      <mat-dialog-actions align="end">
        <button mat-button mat-dialog-close>Close</button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [
    `
      .dialog-content {
        text-align: center;
        padding: 16px;
      }
      .dialog-image {
        max-width: 100%;
        max-height: 80vh;
        object-fit: contain;
        border-radius: 8px;
        border: 1px solid rgba(0, 0, 0, 0.1);
      }
      :host-context(.dark-theme) .dialog-image {
        border: 1px solid rgba(255, 255, 255, 0.1);
      }
    `
  ],
  standalone: true,
  imports: [MatDialogModule, MatButtonModule]
})
export class ImageDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ImageDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { imageSrc: string; productName: string }
  ) {}
}