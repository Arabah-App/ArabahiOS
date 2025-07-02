//
//  NotesViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class NotesViewModelTests: XCTestCase {

    private var viewModel: NotesViewModel!
    private var mockService: MockNotesService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNotesService()
        viewModel = NotesViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func test_getNotesAPI_success() {
        let expectation = XCTestExpectation(description: "getNotesAPI success")

        let response = GetNotesModal(success: true, code: 200, message: "ok", body: nil)

        mockService.getNotesAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2) // loading → success
            .sink { state in
                if case .getNotesSuccess = state {
                    XCTAssertEqual(self.viewModel.modal?.count, 1)
                    XCTAssertEqual(self.viewModel.filteredModal.count, 1)
                    expectation.fulfill()
                } else {
                    XCTFail("Unexpected state: \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.getNotesAPI()
        wait(for: [expectation], timeout: 1.0)
    }

    func test_getNotesAPI_failure() {
        let expectation = XCTestExpectation(description: "getNotesAPI failure")

        mockService.getNotesAPIPublisher = Fail(error: NetworkError.serverError(message: "Server Error"))
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2) // loading → failure
            .sink { state in
                if case .getNotesFailure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Server Error"))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure state")
                }
            }
            .store(in: &cancellables)

        viewModel.getNotesAPI()
        wait(for: [expectation], timeout: 1.0)
    }

    func test_filterNotes_withText() {

        viewModel.filterNotes(searchText: "milk")
        XCTAssertEqual(viewModel.filteredModal.count, 1)
        XCTAssertEqual(viewModel.filteredModal.first?.id, "1")
    }

    func test_filterNotes_emptySearchShowsAll() {

        viewModel.filterNotes(searchText: "")
        XCTAssertEqual(viewModel.filteredModal.count, 2)
    }

    func test_removeNote_keepsMinimumOne() {
        viewModel.texts = [NotesCreate(text: "First Note")]
        viewModel.removeNote(at: 0)
        XCTAssertEqual(viewModel.texts.count, 1)
    }

    func test_appendEmptyNote_addsNote() {
        let initialCount = viewModel.texts.count
        viewModel.appendEmptyNote()
        XCTAssertEqual(viewModel.texts.count, initialCount + 1)
    }

    func test_updateNote_validIndex() {
        viewModel.texts = [NotesCreate(text: "Old")]
        viewModel.updateNote(at: 0, with: "Updated")
        XCTAssertEqual(viewModel.texts[0].text, "Updated")
    }

    func test_createNotesGetListAPI_success() {
        let expectation = XCTestExpectation(description: "createNotesGetListAPI success")

        let mockResponse = CreateNoteListModal(
            success: true,
            code: 200,
            message: "Fetched",
            body: nil
        )

        mockService.createNotesGetListAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2) // idle → loading → success
            .sink { state in
                if case .notesListSuccess(let result) = state {
                    XCTAssertEqual(result.count, 1)
                    XCTAssertEqual(result[0].text, "Template Note")
                    expectation.fulfill()
                } else {
                    XCTFail("Unexpected state: \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.createNotesGetListAPI()
        wait(for: [expectation], timeout: 1.0)
    }

    
    
    func test_createNotesAPI_success() {
        let expectation = XCTestExpectation(description: "createNotesAPI success")

        viewModel.texts = [NotesCreate(text: "Test")]

        mockService.createNotesAPIPublisher = Just(CreateNotesModal(success: true, code: 200, message: "created", body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .createNotesSuccess = state {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected createNotesSuccess")
                }
            }
            .store(in: &cancellables)

        viewModel.createNotesAPI(id: "")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_notesDeleteAPI_success() {
        let expectation = XCTestExpectation(description: "notesDeleteAPI success")

        mockService.notesDeleteAPIPublisher = Just(NewCommonString(success: true, code: 200, message: "deleted",body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .notesDeleteSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.notesDeleteAPI(id: "1")
        wait(for: [expectation], timeout: 1.0)
    }
}

