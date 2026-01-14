import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# Unit tests for Mimir XRD
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: Minimal input renders Helm release
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-helm-release"
        spec = {
            compositionPath = "apis/mimirs/composition.yaml"
            xrdPath = "apis/mimirs/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "Mimir"
                metadata.name = "test-mimir"
                spec = {
                    clusterName = "test-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "test-mimir"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: Custom labels are applied and merged with defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-labels-merged-with-defaults"
        spec = {
            compositionPath = "apis/mimirs/composition.yaml"
            xrdPath = "apis/mimirs/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "Mimir"
                metadata.name = "labeled-mimir"
                spec = {
                    clusterName = "test-cluster"
                    labels = {
                        team = "platform"
                        environment = "staging"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "labeled-mimir"
                        labels = {
                            "hops.ops.com.ai/managed" = "true"
                            "hops.ops.com.ai/mimir" = "labeled-mimir"
                            team = "platform"
                            environment = "staging"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: overrideAllValues replaces defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "override-all-values"
        spec = {
            compositionPath = "apis/mimirs/composition.yaml"
            xrdPath = "apis/mimirs/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "Mimir"
                metadata.name = "override-test"
                spec = {
                    clusterName = "my-cluster"
                    helm.mimir.overrideAllValues = {
                        fullnameOverride = "custom-mimir"
                        minio.enabled = False
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "override-test"
                    spec.forProvider.values = {
                        fullnameOverride = "custom-mimir"
                        minio.enabled = False
                    }
                }
            ]
        }
    }
]

items = _items
