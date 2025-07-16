//
//  NotesViewModel.swift
//  ARABAH
//
//  ViewModel for managing notes (creation, editing, deletion, and listing)
//

import UIKit
import Combine

/// Handles all note-related operations including CRUD and search functionality
final class NotesViewModel {

    // MARK: - Properties
    
    /// Current state that views can observe
    @Published private(set) var notesListState: AppState<[NotesText]> = .idle
    @Published private(set) var notesDetailState: AppState<CreateNotesModalBody> = .idle
    @Published private(set) var notesDeleteState: AppState<NewCommonString> = .idle
    @Published private(set) var createNoteState: AppState<CreateNotesModal> = .idle
    @Published private(set) var getNotesState: AppState<GetNotesModal> = .idle
    
    /// All notes fetched from the server
    @Published private(set) var modal: [GetNotesModalBody]? = []
    
    /// Current note texts being edited/created (local state)
    @Published var texts: [NotesCreate] = [NotesCreate(text: "")]
    
    /// Notes filtered by search query
    @Published var filteredModal: [GetNotesModalBody] = []
    
    /// Stores Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Service handling note-related network operations
    private let networkService: NotesServicesProtocol

    // MARK: - Initialization
    
    /// Creates a new NotesViewModel
    /// - Parameter networkService: Service for note operations (defaults to NotesServices)
    init(networkService: NotesServicesProtocol = NotesServices()) {
        self.networkService = networkService
    }

    // MARK: - Note Text Management
    
    /// Updates text at specific index
    func updateNote(at index: Int, with text: String) {
        guard texts.indices.contains(index) else { return }
        texts[index].text = text
    }

    /// Adds a new empty note field
    func appendEmptyNote() {
        texts.append(NotesCreate(text: ""))
    }

    /// Removes note at specific index (keeps at least one note)
    func removeNote(at index: Int) {
        guard texts.indices.contains(index), texts.count > 1 else { return }
        texts.remove(at: index)
    }

    /// Replaces all current notes with new content
    func replaceAllNotes(with newTexts: [NotesText]) {
        if newTexts.isEmpty {
            texts = [NotesCreate(text: "")]  // Ensure we always have at least one note
        } else {
            texts = newTexts.map { NotesCreate(text: $0.text) }
        }
    }

    /// Filters notes based on search text
    func filterNotes(searchText: String) {
        guard !searchText.isEmpty else {
            filteredModal = modal ?? []  // Show all when search is empty
            return
        }
        
        filteredModal = modal?.filter { note in
            note.notesText?.contains {
                $0.text?.lowercased().contains(searchText.lowercased()) == true
            } ?? false
        } ?? []
    }

    /// Resets search filter to show all notes
    func resetFilter() {
        filteredModal = modal ?? []
    }

    /// Removes a note model at specific index
    func removeModel(at index: Int) {
        modal?.remove(at: index)
    }

    // MARK: - API Methods
    
    /// Fetches all notes from server
    func getNotesAPI() {
        getNotesState = .loading
        networkService.getNotesAPI()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.getNotesState = .failure(error)
                }
            } receiveValue: { [weak self] (response: GetNotesModal) in
                guard let contentBody = response.body else {
                    self?.getNotesState = .failure(.invalidResponse)
                    return
                }
                self?.modal = contentBody
                self?.filteredModal = contentBody  // Initialize filtered list
                self?.getNotesState = .success(response)
            }
            .store(in: &cancellables)
    }

    /// Fetches notes list (alternative endpoint)
    func createNotesGetListAPI() {
        notesListState = .loading
        networkService.createNotesGetListAPI()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.notesListState = .failure(error)
                }
            } receiveValue: { [weak self] (response: CreateNoteListModal) in
                guard let contentBody = response.body else {
                    self?.notesListState = .failure(.invalidResponse)
                    return
                }
                self?.notesListState = .success(contentBody)
            }
            .store(in: &cancellables)
    }

    /// Fetches details for a specific note
    func getNotesDetailAPI(id: String) {
        notesDetailState = .loading
        
        networkService.getNotesDetailAPI(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.notesDetailState = .failure(error)
                }
            } receiveValue: { [weak self] (response: CreateNotesModal) in
                guard let contentBody = response.body else {
                    self?.notesDetailState = .failure(.invalidResponse)
                    return
                }
                
                
                // Update local text state with fetched content
                if let notesArray = contentBody.notesText, !notesArray.isEmpty {
                    self?.texts = notesArray.map { NotesCreate(text: $0.text) }
                } else {
                    self?.texts = [NotesCreate(text: "")]  // Default empty note
                }
                
                self?.notesDetailState = .success(contentBody)
            }
            .store(in: &cancellables)
    }

    /// Deletes a specific note
    func notesDeleteAPI(id: String) {
        notesDeleteState = .loading
        
        networkService.notesDeleteAPI(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.notesDeleteState = .failure(error)
                }
            } receiveValue: { [weak self] (response: NewCommonString) in
                self?.notesDeleteState = .success(response)
            }
            .store(in: &cancellables)
    }

    /// Creates or updates a note
    func createNotesAPI(id: String) {
        createNoteState = .loading
        
        // Filter out empty notes before saving
        let nonEmptyNotes = texts.filter {
            !($0.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        }
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(nonEmptyNotes)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                networkService.createNotesAPI(jsonString: jsonString, id: id)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        if case .failure(let error) = completion {
                            self?.createNoteState = .failure(error)
                        }
                    } receiveValue: { [weak self] (response: CreateNotesModal) in
                        self?.createNoteState = .success(response)
                    }
                    .store(in: &cancellables)
            }
        } catch {
            print("JSON Encoding error: \(error)")
            // Consider adding error state handling here
        }
    }
}
