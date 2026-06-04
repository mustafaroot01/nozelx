import React from 'react';
import { ChevronRight, ChevronLeft, Search } from 'lucide-react';

export default function DataTable({ 
  title,
  subtitle,
  headers = [], 
  data = [], 
  loading = false,
  searchPlaceholder = 'ابحث في الجدول...',
  searchValue = '',
  onSearchChange,
  currentPage = 1,
  totalPages = 1,
  onPageChange,
  renderRow,
  actionButton
}) {
  return (
    <div className="bg-white dark:bg-dark-900 border border-gray-100 dark:border-dark-800 rounded-3xl shadow-premium overflow-hidden">
      {/* Table Header Section */}
      <div className="p-6 border-b border-gray-100 dark:border-dark-800 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="font-extrabold text-lg text-gray-800 dark:text-dark-100">{title}</h3>
          {subtitle && <p className="text-xs text-gray-400 mt-0.5">{subtitle}</p>}
        </div>

        <div className="flex items-center gap-3">
          {onSearchChange && (
            <div className="relative w-64">
              <span className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-gray-400">
                <Search size={16} />
              </span>
              <input
                type="text"
                placeholder={searchPlaceholder}
                value={searchValue}
                onChange={(e) => onSearchChange(e.target.value)}
                className="w-full pr-9 pl-3 py-1.5 rounded-xl border border-gray-200 focus:border-primary-400 focus:outline-none dark:bg-dark-950 dark:border-dark-800 text-xs transition-colors"
              />
            </div>
          )}
          {actionButton}
        </div>
      </div>

      {/* Table Body Container */}
      <div className="overflow-x-auto">
        <table className="w-full text-right border-collapse">
          <thead>
            <tr className="bg-gray-50/75 dark:bg-dark-950/40 border-b border-gray-100 dark:border-dark-800 text-xs font-bold text-gray-500 dark:text-dark-400">
              {headers.map((h, i) => (
                <th key={i} className="px-6 py-4 font-bold">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 dark:divide-dark-800 text-sm">
            {loading ? (
              // Loading Skeleton state
              Array.from({ length: 5 }).map((_, rIdx) => (
                <tr key={rIdx} className="animate-pulse">
                  {headers.map((_, hIdx) => (
                    <td key={hIdx} className="px-6 py-4.5">
                      <div className="h-4 bg-gray-100 dark:bg-dark-800 rounded-md w-full"></div>
                    </td>
                  ))}
                </tr>
              ))
            ) : data.length === 0 ? (
              // Empty state
              <tr>
                <td colSpan={headers.length} className="px-6 py-12 text-center text-gray-400">
                  <div className="flex flex-col items-center justify-center gap-2">
                    <span className="text-sm">لا توجد بيانات متاحة حالياً</span>
                  </div>
                </td>
              </tr>
            ) : (
              data.map((row, idx) => renderRow(row, idx))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination Footer */}
      {totalPages > 1 && (
        <div className="p-4 border-t border-gray-100 dark:border-dark-800 flex items-center justify-between">
          <span className="text-xs text-gray-400">
            الصفحة {currentPage} من {totalPages}
          </span>
          <div className="flex items-center gap-1">
            <button
              onClick={() => onPageChange(currentPage - 1)}
              disabled={currentPage === 1}
              className="p-1.5 rounded-lg border border-gray-200 dark:border-dark-800 text-gray-500 dark:text-dark-400 hover:bg-gray-50 dark:hover:bg-dark-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              aria-label="Previous Page"
            >
              <ChevronRight size={16} />
            </button>
            <button
              onClick={() => onPageChange(currentPage + 1)}
              disabled={currentPage === totalPages}
              className="p-1.5 rounded-lg border border-gray-200 dark:border-dark-800 text-gray-500 dark:text-dark-400 hover:bg-gray-50 dark:hover:bg-dark-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              aria-label="Next Page"
            >
              <ChevronLeft size={16} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
