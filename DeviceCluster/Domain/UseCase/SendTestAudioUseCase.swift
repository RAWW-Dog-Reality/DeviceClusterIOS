import Foundation

protocol SendTestAudioUseCase {
    func execute() async throws
}

final class SendTestAudioUseCaseFakeImpl: SendTestAudioUseCase {
    func execute() async throws {}
}

final class SendTestAudioUseCaseImpl: SendTestAudioUseCase {
    private let peerRepository: PeerRepository

    init(peerRepository: PeerRepository) {
        self.peerRepository = peerRepository
    }

    func execute() async throws {
        guard let url = Bundle.main.url(forResource: "test_audio", withExtension: "mp3") else {
            throw DomainError.generic
        }
        let data = try Data(contentsOf: url)
        let wrapped = PayloadDTO(data: data, type: .audio).encode()
        try peerRepository.sendDataToConnectedPeers(wrapped)
    }
}
