import Foundation

protocol ObserveAudioUseCase {
    func execute() -> AsyncStream<Data>
}

final class ObserveAudioUseCaseFakeImpl: ObserveAudioUseCase {
    func execute() -> AsyncStream<Data> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}

final class ObserveAudioUseCaseImpl: ObserveAudioUseCase {
    private let peerRepository: PeerRepository

    init(peerRepository: PeerRepository) {
        self.peerRepository = peerRepository
    }

    func execute() -> AsyncStream<Data> {
        let dataStream = peerRepository.observeIncomingData()
        return AsyncStream { continuation in
            let task = Task {
                for await data in dataStream {
                    let payload = PayloadDTO.decode(data)
                    guard payload.type == .audio else { continue }
                    continuation.yield(payload.data)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
